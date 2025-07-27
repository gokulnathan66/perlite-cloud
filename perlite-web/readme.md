docker run -d \
  --name perlite \
  -p 80:80 \
  -v $(pwd)/Demo:/var/www/perlite/Demo:ro \
  -e NOTES_PATH=Demo \
  -e HOME_FILE=README \
  -e SHOW_TOC=true \
  -e SHOW_LOCAL_GRAPH=true \
  -e FONT_SIZE=15 \
  -e SITE_TITLE="My Vault" \
  -e SITE_NAME="Perlite" \
  perlite-server
