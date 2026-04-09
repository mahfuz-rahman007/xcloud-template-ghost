services:
  db:
    container_name: ghost-db-{{ site_name }}
    image: mysql:8.4
    restart: always
    env_file:
      - .env
    command:
      - --mysql-native-password=ON
    volumes:
      - ghost_db:/var/lib/mysql
    healthcheck:
      test: ["CMD-SHELL", "mysqladmin ping -h 127.0.0.1 -uroot -p${MYSQL_ROOT_PASSWORD} --silent"]
      interval: 10s
      timeout: 5s
      retries: 10
      start_period: 30s
    networks:
      - {{ network_name }}

  ghost:
    container_name: ghost-{{ site_name }}
    image: ghost:{{ app_version | default:"6" }}-alpine
    restart: always
    env_file:
      - .env
    depends_on:
      db:
        condition: service_healthy
    volumes:
      - ghost_content:/var/lib/ghost/content
    ports:
      - "127.0.0.1:{{ ports.main }}:2368"
    healthcheck:
      test: ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://127.0.0.1:2368/ || exit 1"]
      interval: 15s
      timeout: 5s
      retries: 10
      start_period: 40s
    networks:
      - {{ network_name }}

volumes:
  ghost_content:
  ghost_db:

networks:
  {{ network_name }}:
    driver: bridge
