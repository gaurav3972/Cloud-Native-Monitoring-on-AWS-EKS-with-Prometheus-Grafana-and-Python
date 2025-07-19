# 🐳 WordPress + MySQL Docker Setup 

## 📋 Prerequisites

Ensure the following are installed on your system:

- [Docker Engine](https://docs.docker.com/get-docker/)
- Internet connection (to pull Docker images)

---

## ⚙️ Step-by-Step Instructions

### ✅ Step 1: Start MySQL Container

Start a MySQL container named `mydbcont` with a root password and create a default database `wordpressdb`.

```bash
docker run -d \
  --name mydbcont \
  -e MYSQL_ROOT_PASSWORD='Pass@123' \
  -e MYSQL_DATABASE=wordpressdb \
  mysql
````

**Environment Variables Explained:**

* `MYSQL_ROOT_PASSWORD`: Sets the root password for MySQL.
* `MYSQL_DATABASE`: Automatically creates a database named `wordpressdb`.

> ⚠️ Use single quotes `'Pass@123'` to avoid shell interpretation of special characters like `@`.

---

### 🔍 Step 2: Verify MySQL Is Running

Check the running containers:

```bash
docker container ls
```

You should see `mydbcont` in the list, running the `mysql` image.

---

### 🐚 Step 3: Connect to the MySQL Container

Access the container shell:

```bash
docker exec -it mydbcont /bin/bash
```

Log into MySQL:

```bash
mysql -u root -p
```

When prompted, enter the root password: `Pass@123`.

Inside the MySQL prompt, verify the database:

```sql
SHOW DATABASES;
```

Expected output:

```
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| wordpressdb        |
+--------------------+
```

Exit MySQL and the shell:

```sql
exit
exit
```

---

### 📝 Step 4: Start WordPress Container

Now run the WordPress container and link it to MySQL:

```bash
docker run -d \
  --name worpress_cont \
  -p 80:80 \
  -e WORDPRESS_DB_HOST=mydbcont \
  -e WORDPRESS_DB_USER=root \
  -e WORDPRESS_DB_PASSWORD='Pass@123' \
  -e WORDPRESS_DB_NAME=wordpressdb \
  --link mydbcont:mysql \
  wordpress
```

**Environment Variables Explained:**

* `WORDPRESS_DB_HOST`: Hostname of the MySQL container (`mydbcont`).
* `WORDPRESS_DB_USER`: MySQL user (`root`).
* `WORDPRESS_DB_PASSWORD`: MySQL root password.
* `WORDPRESS_DB_NAME`: The name of the MySQL database created earlier.

> 🧠 Note: `--link` is considered legacy. For production or Docker Compose, use user-defined networks.

---

### 🌐 Step 5: Access WordPress

Open your browser and visit:

```
http://localhost
```

You should see the WordPress installation screen where you can select your language and proceed with the site setup.

---

## 🧪 Verifying the Setup

Check running containers again:

```bash
docker container ls
```

You should see both `mydbcont` and `worpress_cont` running.

If WordPress is not accessible:

* Make sure port `80` is not in use by another service.
* Check container logs:

```bash
docker logs worpress_cont
```

---

## 🧹 Cleanup

To stop and remove the containers:

```bash
docker stop worpress_cont mydbcont
docker rm worpress_cont mydbcont
```

To remove images (optional):

```bash
docker rmi wordpress mysql
```

---

## 🧰 Tips

* Use Docker volumes to persist data between restarts.
* Use Docker Compose for better manageability (see below).
* Never use root credentials in production; create a dedicated user instead.

---

## 📦 Bonus: Docker Compose Alternative (Optional)

Here’s a `docker-compose.yml` file for the same setup:

```yaml
version: '3.8'

services:
  db:
    image: mysql
    container_name: mydbcont
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: Pass@123
      MYSQL_DATABASE: wordpressdb
    volumes:
      - db_data:/var/lib/mysql

  wordpress:
    image: wordpress
    container_name: worpress_cont
    restart: always
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: root
      WORDPRESS_DB_PASSWORD: Pass@123
      WORDPRESS_DB_NAME: wordpressdb
    depends_on:
      - db

volumes:
  db_data:
```

Run with:

```bash
docker-compose up -d
```

---

## 📄 License

This setup is provided as-is for educational and development purposes.

---
### ✅ Summary of the WordPress + MySQL Docker Setup
---

#### 🔧 What You Do:

1. **Run MySQL Container**:

   * Name: `mydbcont`
   * Root password: `Pass@123`
   * Creates DB: `wordpressdb`

2. **Verify MySQL**:

   * Connect to MySQL inside the container
   * Confirm the `wordpressdb` database exists

3. **Run WordPress Container**:

   * Name: `worpress_cont`
   * Linked to `mydbcont`
   * Exposes WordPress on `http://localhost`

4. **Access WordPress in Browser**:

   * Go to `http://localhost` and complete setup

5. **Cleanup** (optional):

   * Stop & remove containers:
     `docker stop worpress_cont mydbcont && docker rm worpress_cont mydbcont`

---


