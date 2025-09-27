{ ... }:
{
  systemd.timers."backup-notes" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "5m";
      Unit = "backup-notes.service";
    };
  };

  systemd.services."backup-notes" = {
    script = ''
      # Navigate to the notes directory
      cd /home/Root/vaults/notes 
      # Fetch the latest changes from the remote repository
      /home/Root/.nix-profile/bin/git fetch origin
        

      # Pull the latest changes
      /home/Root/.nix-profile/bin/git pull origin main

      # Add all new and changed files to the commit
      /home/Root/.nix-profile/bin/git  add .

      # Commit the changes with the current date as the message
      DATE=$(date +'%Y-%m-%d %H:%M:%S')
      /home/Root/.nix-profile/bin/git commit -m "auto backup: $DATE"

      # Push the commit to the remote repository
      /home/Root/.nix-profile/bin/git push origin main
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "Root";
      Group = "users";
      SuccessExitStatus = "0 1 7";
    };
  };
}
