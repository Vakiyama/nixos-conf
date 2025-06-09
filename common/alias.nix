{ ... }:
{
  environment.shellAliases = {
    rm = "rip";
    vi = "nvim";
    ls = "exa --icons -F -H --group-directories-first --git -1";
    lt = "exa --tree --level=2 --long --icons --git";
  };

}
