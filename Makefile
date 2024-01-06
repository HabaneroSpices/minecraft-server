.POSIX:

start: ## docker-compose up --build ## (starts the minecraft server)
	@echo "Starting Minecraft Server..."; \
	docker-compose up -d --build;
	
stop: ## docker-compose stop --rmi all --remove-orphans: ## (stops and cleans up images, but keeps data)
	@echo "Stopping Minecraft Server and cleaning up..."; \
	docker-compose down --rmi all --remove-orphans;

attach: ## docker attach mcserver ## (attaches to minecraft paper jar for issuing commands)
	@echo "Attaching to Minecraft..."; \
	echo "Ctrl-C stops minecraft and exits!"; \
	echo "Ctrl-P Ctrl-Q detataches."; \
	echo ""; \
	echo "Type "help" for help."; \
	docker attach minecraft-server;
