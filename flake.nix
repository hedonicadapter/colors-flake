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
    palette = {
      base00 = "#ebdfd8";
      base01 = "#e3d2c8";
      base02 = "#d1b5a5";
      base03 = "#967b6b";
      base04 = "#593e2e";
      base05 = "#382f29";
      base06 = "#2b2420";
      base07 = "#171413";
      base08 = "#a83800";
      base09 = "#790239";
      base0A = "#13578E";
      base0B = "#247F94";
      base0C = "#277A00";
      base0D = "#A87E00";
      base0E = "#a86500";
      base0F = "#94001b";
    };

    sanitizeColor = color:
      if builtins.substring 0 1 color == "#"
      then builtins.substring 1 (builtins.stringLength color - 1) color
      else color;

    toHex = x: let
      hex = nixpkgs.lib.toHexString (builtins.floor x);
    in
      if builtins.stringLength hex == 1
      then "0${hex}"
      else hex;

    hexColorTo0xAARRGGBB = color: alpha: let
      cleanColor = sanitizeColor color;

      rr = builtins.substring 0 2 cleanColor;
      gg = builtins.substring 2 2 cleanColor;
      bb = builtins.substring 4 2 cleanColor;

      alphaInt = builtins.floor (alpha * 255);

      aa = toHex alphaInt;
    in "0x${aa}${rr}${gg}${bb}";

    rgbToHex = r: g: b: "#${toHex r}${toHex g}${toHex b}";

    darken = color: percentage: let
      cleanColor = sanitizeColor color;
      rgb = nix-colors.lib.conversions.hexToRGB cleanColor;
      darken = c: let
        darkenedValue = c * (1 - percentage);
      in
        builtins.floor (
          if darkenedValue < 0
          then 0
          else if darkenedValue > 255
          then 255
          else darkenedValue
        );
      darkenedRgb = {
        r = darken (builtins.elemAt rgb 0);
        g = darken (builtins.elemAt rgb 1);
        b = darken (builtins.elemAt rgb 2);
      };
    in
      rgbToHex darkenedRgb.r darkenedRgb.g darkenedRgb.b;

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

    palette_opaque = builtins.listToAttrs (
      builtins.filter (x: isOpaque (builtins.getAttr x.name palette))
      (builtins.map (name: {
          inherit name;
          value = builtins.getAttr name palette;
        })
        (builtins.attrNames palette))
    );

    colorNames = builtins.attrNames palette;
    cssColorVariables = builtins.concatStringsSep "\n" (
      builtins.map (color: "--color-${color}: ${palette.${color}};") colorNames
    );

    isDarkColor = color: let
      sanitizeColor = color:
        if builtins.substring 0 1 color == "#"
        then builtins.substring 1 (builtins.stringLength color - 1) color
        else color;

      sanitizedColor = sanitizeColor color;

      hexToRgbComponent = idx:
        builtins.fromString (builtins.substring idx 2 sanitizedColor) / 255.0;

      r = hexToRgbComponent 0;
      g = hexToRgbComponent 2;
      b = hexToRgbComponent 4;

      luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b;
    in
      luminance < 0.5;
  in {
    palette = palette;
    palette_opaque = palette_opaque;
    transparentize = transparentize;
    darken = darken;
    cssColorVariables = cssColorVariables;
    hexColorTo0xAARRGGBB = hexColorTo0xAARRGGBB;
    isDarkColor = isDarkColor;
  };
}
