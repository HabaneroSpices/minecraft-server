#!/bin/sh
#
set -e
set -x

DOCKER_USER="minecraft"
DOCKER_GROUP="minecraft"

if ! id "$DOCKER_USER" >/dev/null 2>&1; then
	echo "First time run detected. Starting inital setup..."

	USER_ID=${PUID:-9001}
	GROUP_ID=${PGID:-9001}
	echo -e "\tUsing $USER_ID:$GROUP_ID"

	addgroup --gid $GROUP_ID $DOCKER_GROUP
	# --gecos flag might be depricated soon.
	adduser $DOCKER_USER --shell /bin/sh --uid $USER_ID --ingroup $DOCKER_GROUP --disabled-password --gecos ""

	chown -vR $USER_ID:$GROUP_ID /opt/minecraft
	chmod -vR ug+rwx /opt/minecraft

	# Set permissions on data volume, if enabled.
	if [ "$SKIP_PERM_CHECK" != "true" ]; then
		chown -vR $USER_ID:$GROUP_ID /data
	fi
fi

export HOME=/home$DOCKER_USER
exec gosu $DOCKER_USER:$DOCKER_GROUP java -jar -Xms$MEMORY_SIZE -Xmx$MEMORY_SIZE $JAVA_FLAGS /opt/minecraft/paper.jar $PAPER_FLAGS nogui
