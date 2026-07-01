{ pkgs-unstable, lib, pkgs, config, ... }:
let
  modelDir = "/var/lib/models";
  modelFile = "Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf";
  modelPath = "${modelDir}/${modelFile}";
  llamaSwapPort = "8089";
  webuiPort = "9090";

  remoteApiBase = "https://llm.gaugenumerics.com/v1";

  llama-cpp = pkgs-unstable.llama-cpp.override { cudaSupport = true; };
  llama-server = lib.getExe' llama-cpp "llama-server";
  llamaSwapConfig = (pkgs-unstable.formats.yaml { }).generate "llama-swap-config.yaml" {
    healthCheckTimeout = 180;
    models = {
      "qwen3.6:27b" = {
        cmd = "${llama-server} --port \${PORT} -m ${modelPath} --flash-attn on --cache-type-k q8_0 --cache-type-v q8_0 --ctx-size 262144 --jinja --temp 0.6 --top-p 0.95 --top-k 20 --no-webui";
        ttl = 600;
      };
    };
  };
in
{
  sops.defaultSopsFile = ./secrets.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  # The friend's token.
  sops.secrets.ethan_server_api_key = { };

  # Rendered to a file outside the Nix store at activation, with the
  # placeholder substituted. Local gets a dummy key; remote gets the token.
  # This order MUST line up with OPENAI_API_BASE_URLS below.
  sops.templates."open-webui.env".content = ''
    OPENAI_API_KEYS=dummy;${config.sops.placeholder.ethan_server_api_key}
  '';

  sops.secrets.ethan_server_api_key = {
    owner = "Root";   # your normal user; default sops owner is root-only
  };

  systemd.tmpfiles.rules = [
    "d ${modelDir} 0755 root root -"
  ];

  systemd.services.download-qwen36 = {
    description = "Download Qwen3.6-27B MTP GGUF model";
    wantedBy = [ "multi-user.target" ];
    before = [ "llama-swap.service" ];
    path = [ pkgs.aria2 ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "download-qwen36" ''
        if [ ! -f "${modelPath}" ]; then
          echo "Downloading Qwen3.6-27B MTP..."
          aria2c \
            --continue=true \
            --max-connection-per-server=8 \
            --split=8 \
            --dir="${modelDir}" \
            --out="${modelFile}" \
            "https://huggingface.co/unsloth/Qwen3.6-35B-A3B-GGUF/resolve/main/${modelFile}?download=true"
        else
          echo "Model already present, skipping."
        fi
      '';
    };
  };

  systemd.services.llama-swap = {
    description = "llama-swap model proxy";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "download-qwen36.service" ];
    requires = [ "download-qwen36.service" ];
    serviceConfig = {
      ExecStart = "${pkgs-unstable.llama-swap}/bin/llama-swap --config ${llamaSwapConfig} --listen 127.0.0.1:${llamaSwapPort}";
      Restart = "on-failure";
      TimeoutStartSec = 300;
    };
  };

  systemd.services.open-webui = {
    description = "Open WebUI";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "llama-swap.service" ];
    environment = {
      # Not secret. Order matches OPENAI_API_KEYS in the sops template.
      OPENAI_API_BASE_URLS = "http://127.0.0.1:${llamaSwapPort}/v1;${remoteApiBase}";
      PORT = webuiPort;
      HOST = "127.0.0.1";
      DATA_DIR = "/var/lib/open-webui";
    };
    serviceConfig = {
      EnvironmentFile = config.sops.templates."open-webui.env".path;
      ExecStart = "${pkgs-unstable.open-webui}/bin/open-webui serve --port ${webuiPort}";
      Restart = "on-failure";
      StateDirectory = "open-webui";
    };
  };
}
