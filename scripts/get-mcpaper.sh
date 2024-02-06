## Credit: https://github.com/mtoensing/Docker-Minecraft-PaperMC-Server/blob/latest/getpaperserver.sh
PAPER_VERSION=$1
LATEST_BUILD=$(curl -s "https://papermc.io/api/v2/projects/paper/versions/${PAPER_VERSION}" | jq '.builds[-1]')
LATEST_DOWNLOAD=$(curl -s "https://papermc.io/api/v2/projects/paper/versions/${PAPER_VERSION}/builds/${LATEST_BUILD}" | jq '.downloads.application.name' -r)

PAPER_DOWNLOAD_CHECKSUM="$(curl -s "https://papermc.io/api/v2/projects/paper/versions/${PAPER_VERSION}/builds/${LATEST_BUILD}" | jq '.downloads.application.sha256' -r)"
PAPER_DOWNLOAD_URL="https://papermc.io/api/v2/projects/paper/versions/${PAPER_VERSION}/builds/${LATEST_BUILD}/downloads/${LATEST_DOWNLOAD}"

echo "-----------------"
echo "Downloading PaperMC Version: $PAPER_VERSION | Build: $LATEST_BUILD"
echo "Sha256: $PAPER_DOWNLOAD_CHECKSUM"
echo "-----------------"
curl -s -o paperclip.jar ${PAPER_DOWNLOAD_URL}

# Verify checksum
echo "$PAPER_DOWNLOAD_CHECKSUM paperclip.jar" | sha256sum --check --status || (
	echo "Checksum did not match downloaded content"
	exit 1
)
