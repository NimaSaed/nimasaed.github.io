{
  description = "Resume builder with Pandoc and WeasyPrint";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      # Support both Intel and Apple Silicon Macs, plus Linux
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      # Development shell: `nix develop`
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              pandoc
              python312Packages.weasyprint
            ];

            shellHook = ''
              echo "Resume Builder Environment"
              echo ""
              echo "Commands:"
              echo "  nix run .#build              - Generate resume.pdf (default)"
              echo "  nix run .#build -- file.md   - Generate file.pdf"
              echo "  nix run .#html               - Generate resume.html (default)"
              echo "  nix run .#html -- file.md    - Generate file.html"
              echo ""
            '';
          };
        });

      # Apps: `nix run .#build`
      apps = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};

          buildPdf = pkgs.writeShellScriptBin "build-resume-pdf" ''
            set -e
            INPUT="''${1:-resume.md}"
            OUTPUT="''${INPUT%.md}.pdf"
            echo "Building $OUTPUT from $INPUT..."
            ${pkgs.pandoc}/bin/pandoc "$INPUT" \
              --standalone \
              --css=resume-style.css \
              -o - | ${pkgs.python312Packages.weasyprint}/bin/weasyprint - "$OUTPUT"
            echo "Done! Created $OUTPUT"
          '';

          buildHtml = pkgs.writeShellScriptBin "build-resume-html" ''
            set -e
            INPUT="''${1:-resume.md}"
            OUTPUT="''${INPUT%.md}.html"
            echo "Building $OUTPUT from $INPUT..."
            ${pkgs.pandoc}/bin/pandoc "$INPUT" \
              --standalone \
              --css=resume-style.css \
              --metadata title="Resume" \
              -o "$OUTPUT"
            echo "Done! Created $OUTPUT"
          '';
        in
        {
          build = {
            type = "app";
            program = "${buildPdf}/bin/build-resume-pdf";
          };

          html = {
            type = "app";
            program = "${buildHtml}/bin/build-resume-html";
          };

          default = {
            type = "app";
            program = "${buildPdf}/bin/build-resume-pdf";
          };
        });
    };
}
