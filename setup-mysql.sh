#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🗄️  MySQL Setup untuk Kurir ATK${NC}\n"

# Step 1: Check if MySQL is installed
echo -e "${YELLOW}[1/5] Checking MySQL...${NC}"
if ! command -v mysql &> /dev/null; then
    echo -e "${RED}❌ MySQL not found. Please install MySQL first.${NC}"
    exit 1
fi
echo -e "${GREEN}✅ MySQL found${NC}\n"

# Step 2: Create database and user
echo -e "${YELLOW}[2/5] Creating database and user...${NC}"
read -p "Enter MySQL root password (press Enter if no password): " MYSQL_ROOT_PASS

if [ -z "$MYSQL_ROOT_PASS" ]; then
    mysql -u root << EOF
CREATE DATABASE IF NOT EXISTS kurir_atk_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON kurir_atk_db.* TO 'root'@'localhost';
FLUSH PRIVILEGES;
EOF
else
    mysql -u root -p"$MYSQL_ROOT_PASS" << EOF
CREATE DATABASE IF NOT EXISTS kurir_atk_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON kurir_atk_db.* TO 'root'@'localhost';
FLUSH PRIVILEGES;
EOF
fi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Database created${NC}\n"
else
    echo -e "${RED}❌ Failed to create database${NC}"
    exit 1
fi

# Step 3: Update .env file
echo -e "${YELLOW}[3/5] Updating .env configuration...${NC}"
if [ ! -f .env ]; then
    cp .env.example .env
    echo -e "${GREEN}✅ .env file created${NC}"
fi

# Update database connection
sed -i 's/DB_CONNECTION=.*/DB_CONNECTION=mysql/' .env
sed -i 's/DB_HOST=.*/DB_HOST=127.0.0.1/' .env
sed -i 's/DB_PORT=.*/DB_PORT=3306/' .env
sed -i 's/DB_DATABASE=.*/DB_DATABASE=kurir_atk_db/' .env
sed -i 's/DB_USERNAME=.*/DB_USERNAME=root/' .env

echo -e "${GREEN}✅ .env updated${NC}\n"

# Step 4: Run migrations
echo -e "${YELLOW}[4/5] Running Laravel migrations...${NC}"
php artisan key:generate 2>/dev/null
php artisan migrate --force

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Migrations completed${NC}\n"
else
    echo -e "${RED}❌ Migration failed${NC}"
    exit 1
fi

# Step 5: Verify connection
echo -e "${YELLOW}[5/5] Verifying database connection...${NC}"
php artisan tinker << 'EOF'
try {
    DB::connection()->getPdo();
    echo "✅ Database connection successful!\n";
} catch (Exception $e) {
    echo "❌ Connection failed: " . $e->getMessage() . "\n";
}
exit();
EOF

echo -e "${GREEN}\n🎉 MySQL Setup Complete!${NC}"
echo -e "${YELLOW}Database Name: kurir_atk_db${NC}"
echo -e "${YELLOW}Tables created: $(php artisan tinker << 'EOF'
$count = DB::select("SHOW TABLES");
echo count($count);
exit();
EOF
)${NC}"
echo -e "\n${GREEN}Ready to start developing! 🚀${NC}"
