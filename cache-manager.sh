#!/usr/bin/env bash
# 简单的缓存管理工具
# 用于管理 /tmp/cache/buildpack/ 目录下的缓存文件

set -eo pipefail

CACHE_DIR="/tmp/cache/buildpack"

# 显示帮助信息
show_help() {
    echo "Goodrain 包缓存管理工具"
    echo ""
    echo "用法: $0 <command>"
    echo ""
    echo "命令:"
    echo "  stats   - 显示缓存统计信息"
    echo "  clear   - 清理所有缓存"
    echo "  help    - 显示此帮助信息"
    echo ""
    echo "缓存目录: $CACHE_DIR"
}

# 显示缓存统计
show_stats() {
    if [ ! -d "$CACHE_DIR" ]; then
        echo "缓存目录不存在: $CACHE_DIR"
        return
    fi
    
    local file_count=$(find "$CACHE_DIR" -type f | wc -l)
    local total_size=$(du -sh "$CACHE_DIR" 2>/dev/null | cut -f1)
    
    echo "=== Goodrain 包缓存统计 ==="
    echo "缓存目录: $CACHE_DIR"
    echo "缓存文件数量: $file_count"
    echo "缓存总大小: $total_size"
    echo ""
    
    if [ $file_count -gt 0 ]; then
        echo "=== 缓存文件列表 ==="
        find "$CACHE_DIR" -type f -exec ls -lh {} \; | while read -r line; do
            echo "  $line"
        done
    fi
}

# 清理所有缓存
clear_cache() {
    if [ ! -d "$CACHE_DIR" ]; then
        echo "缓存目录不存在: $CACHE_DIR"
        return
    fi
    
    echo "正在清理缓存目录: $CACHE_DIR"
    rm -rf "$CACHE_DIR"/*
    echo "缓存清理完成！"
}

# 主函数
main() {
    case "${1:-help}" in
        "stats")
            show_stats
            ;;
        "clear")
            read -p "确定要清空所有缓存吗？(y/N): " -r
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                clear_cache
            else
                echo "操作已取消"
            fi
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            echo "错误: 未知命令 '$1'"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"
