#!/bin/bash
# 安全更新脚本 - 不会丢失数据

echo "🔄 开始更新服务器..."

# 1. 检查 data 目录是否存在
if [ ! -d "./data" ]; then
    echo "📁 创建 data 目录..."
    mkdir -p ./data
fi

# 2. 备份数据库（如果存在）
if [ -f "./data/database.sqlite" ]; then
    BACKUP_FILE="./data/database_backup_$(date +%Y%m%d_%H%M%S).sqlite"
    echo "💾 备份数据库到 $BACKUP_FILE"
    cp ./data/database.sqlite "$BACKUP_FILE"
    
    # 只保留最近3个备份
    ls -t ./data/database_backup_*.sqlite | tail -n +4 | xargs -r rm
fi

# 3. 停止旧容器（但不删除 volume）
echo "⏸️  停止旧容器..."
docker-compose down

# 4. 重新构建镜像
echo "🔨 构建新镜像..."
docker-compose build

# 5. 启动新容器
echo "🚀 启动新容器..."
docker-compose up -d

# 6. 等待服务启动
echo "⏳ 等待服务启动..."
sleep 3

# 7. 检查服务状态
echo "✅ 检查服务状态..."
docker-compose ps
docker-compose logs --tail=20

echo ""
echo "✨ 更新完成！"
echo ""
echo "📊 数据库信息："
if [ -f "./data/database.sqlite" ]; then
    echo "  ✅ 数据库文件存在"
    echo "  📏 大小: $(du -h ./data/database.sqlite | cut -f1)"
else
    echo "  ⚠️  数据库文件不存在（可能是首次启动）"
fi
echo ""
echo "💡 提示："
echo "  - 如果需要查看日志：docker-compose logs -f"
echo "  - 如果需要重启服务：docker-compose restart"
echo "  - 数据库位置：./data/database.sqlite"