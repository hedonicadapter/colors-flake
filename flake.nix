{
  description = "Global color settings and utils";

  inputs = {
    nix-colors = {url = "github:misterio77/nix-colors";};
  };

  outputs = {
    nixpkgs,
    nix-colors,
    ...
  }: let
    colors = {
      black = "#2b3339"; # base00
      grey = "#323c41"; # base01
      red = "#7fbbb3"; # base08
      red_dim = "#e67e80"; # base0E
      burgundy = "#503946"; # base02
      yellow = "#83c092"; # base0A
      yellow_dim = "#fff9e8"; # base07
      orange = "#d699b6"; # base09
      orange_dim = "#d699b6"; # base0F
      orange_bright = "#d699b6"; # base09
      green = "#dbbc7f"; # base0B
      green_dim = "#e9e8d2"; # base06
      blue = "#a7c080"; # base0D
      blue_dim = "#e69875"; # base0C
      blush = "#7fbbb3"; # base08
      cyan = "#e69875"; # base0C
      cyan_dim = "#a7c080"; # base0D
      white = "#d3c6aa"; # base05
      white_dim = "#fff9e8"; # base07
      beige = "#fff9e8"; # base07
      vanilla_pear = "#d3c6aa"; # base05
    };

    sanitizeColor = color:
      if builtins.substring 0 1 color == "#"
      then builtins.substring 1 (builtins.stringLength color - 1) color
      else color;

    rgbToHex = r: g: b: let
      toHex = x: let
        hex = nixpkgs.lib.toHexString (builtins.floor x);
      in
        if builtins.stringLength hex == 1
        then "0${hex}"
        else hex;
    in "#${toHex r}${toHex g}${toHex b}";

    darken = let
      darkenColor = color: percentage: let
        cleanColor = sanitizeColor color;
        rgb = nix-colors.lib.conversions.hexToRGB cleanColor;

        darken = c: let
          darkenedValue = c - (c * percentage);
        in
          builtins.floor darkenedValue;

        darkenedRgb = {
          r = darken (builtins.elemAt rgb 0);
          g = darken (builtins.elemAt rgb 1);
          b = darken (builtins.elemAt rgb 2);
        };
      in
        rgbToHex darkenedRgb.r darkenedRgb.g darkenedRgb.b;
    in
      darkenColor;

    transparentize = let
      addAlpha = color: alpha: let
        alphaInt = builtins.floor (alpha * 255);
        alphaHex = builtins.substring 0 2 (builtins.toString (100 + alphaInt));

        cleanColor = sanitizeColor color;
        rgb = nix-colors.lib.conversions.hexToRGB cleanColor;
      in
        (rgbToHex (builtins.elemAt rgb 0) (builtins.elemAt rgb 1) (builtins.elemAt rgb 2)) + alphaHex;
    in
      addAlpha;

    isOpaque = color:
      builtins.stringLength color == 7 && builtins.substring 0 1 color == "#";

    colors_opaque = builtins.listToAttrs (
      builtins.filter (x: isOpaque (builtins.getAttr x.name colors))
      (builtins.map (name: {
          inherit name;
          value = builtins.getAttr name colors;
        })
        (builtins.attrNames colors))
    );

    colorNames = builtins.attrNames colors;
    cssColorVariables = builtins.concatStringsSep "\n" (
      builtins.map (color: "--color-${color}: ${colors.${color}};") colorNames
    );
  in {
    colors = colors;
    transparentize = transparentize;
    darken = darken;
    colors_opaque = colors_opaque;
    cssColorVariables = cssColorVariables;
  };
}
