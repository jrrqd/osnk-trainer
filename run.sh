#!/bin/bash

# OSNK Trainer Skill - Main Script
# OSK/OSNK Practice with Performance Tracking

COMMAND="$1"
shift

# Dynamic path detection with GitHub fallback
if [ -n "$OPENCLAW_WORKSPACE" ]; then
    DATA_DIR="$OPENCLAW_WORKSPACE/memory"
    KB_DIR="$OPENCLAW_WORKSPACE/knowledge"
    REPO_DIR="$OPENCLAW_WORKSPACE"
elif [ -d "/root/.openclaw/workspace/memory" ]; then
    DATA_DIR="/root/.openclaw/workspace/memory"
    KB_DIR="/root/.openclaw/workspace/knowledge"
    REPO_DIR="/root/.openclaw/workspace"
else
    DATA_DIR="./memory"
    KB_DIR="./knowledge"
    REPO_DIR="."
fi

mkdir -p "$DATA_DIR"

# Question bank - support both local and GitHub
KB_REPO="https://raw.githubusercontent.com/jrrqd/osnk-question-bank/master"

get_kb_file() {
    local file="$1"
    if [ -f "$KB_DIR/$file" ]; then
        cat "$KB_DIR/$file"
    else
        curl -s "$KB_REPO/$file" 2>/dev/null || echo ""
    fi
}

# Files
STATS_FILE="$DATA_DIR/osnk-stats.json"
PROGRESS_FILE="$DATA_DIR/osnk-progress.json"
CONFIG_FILE="$DATA_DIR/osnk-config.json"

init_stats() {
    if [ ! -f "$STATS_FILE" ]; then
        echo '{"total_attempted":0,"correct":0,"wrong":0,"by_category":{},"by_year":{},"sessions":0,"last_session":""}' > "$STATS_FILE"
    fi
}

get_random_question() {
    year="$1"
    category="$2"
    
    if [ -z "$year" ]; then
        # Get random files from OSK/OSNK
        local files=$(find "$KB_DIR" -name "osk-*.md" -o -name "osnk-*.md" 2>/dev/null | shuf | head -3)
        if [ -z "$files" ]; then
            # Try GitHub
            files="osk-2018.md osk-2019.md osnk-2024.md"
        fi
        for f in $files; do
            if [ -f "$KB_DIR/$f" ]; then
                grep -A10 "^## " "$KB_DIR/$f" | head -20 || echo "No questions found"
            fi
        done
    else
        if [ -f "$KB_DIR/osk-$year.md" ]; then
            shuf -n 1 "$KB_DIR/osk-$year.md" | head -15
        elif [ -f "$KB_DIR/osnk-$year.md" ]; then
            shuf -n 1 "$KB_DIR/osnk-$year.md" | head -15
        else
            # Try download from GitHub
            curl -s "$KB_REPO/osk-$year.md" | head -15 || echo "Year $year not found"
        fi
    fi
}

show_stats() {
    init_stats
    total=$(cat "$STATS_FILE" 2>/dev/null | grep -o '"total_attempted":[0-9]*' | cut -d: -f2)
    correct=$(cat "$STATS_FILE" 2>/dev/null | grep -o '"correct":[0-9]*' | cut -d: -f2)
    wrong=$(cat "$STATS_FILE" 2>/dev/null | grep -o '"wrong":[0-9]*' | cut -d: -f2)
    
    if [ -z "$total" ] || [ "$total" = "0" ]; then
        echo "📊 OSNK Training Stats"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "Belum ada sesi latihan!"
        echo ""
        echo "Mulai: openclaw, give me 5 questions"
    else
        accuracy=$((correct * 100 / total))
        echo "📊 OSNK Training Stats"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📝 Total: $total | ✅ $correct | ❌ $wrong"
        echo "📈 Accuracy: $accuracy%"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    fi
}

show_help() {
    echo "🧠 OSNK Trainer - Latihan OSNK Informatika"
    echo ""
    echo "📝 Contoh perintah:"
    echo "  openclaw, give me 5 questions"
    echo "  openclaw, 10 graph questions"
    echo "  openclaw, random osk 2018"
    echo ""
    echo "⏱️ Speed Run:"
    echo "  openclaw, start speed run 30 minutes"
    echo ""
    echo "📊 Stats:"
    echo "  openclaw, show my stats"
    echo "  openclaw, my progress"
    echo ""
    echo "📚 Bank soal dari: github.com/jrrqd/osnk-question-bank"
}

case "$COMMAND" in
    "stats"|"performance"|"my-stats")
        show_stats
        ;;
        
    "random"|"questions"|"give")
        num="${1:-5}"
        topic="$*"
        
        echo "🎯 $num random questions:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        for i in $(seq 1 $num); do
            echo ""
            echo "Question $i:"
            get_random_question "" "" | head -8
        done
        echo ""
        echo "Ketik: openclaw, answer [your_answer]"
        ;;
        
    "speed"|"speedrun"|"timed")
        duration="${1:-30}"
        echo "⏱️ Speed Run - $duration menit!"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        get_random_question "" "" | head -10
        ;;
        
    "explain"|"what"|"define")
        topic="$*"
        case "$topic" in
            *dynamic*|*dp*)
                echo "📖 Dynamic Programming"
                echo "Teknik optimasi: pecah masalah jadi subproblem"
                echo "- Memoization (top-down)"
                echo "- Tabulation (bottom-up)"
                ;;
            *graph*|*bfs*|*dfs*)
                echo "📖 Graph Traversal"
                echo "BFS: Level by level (Queue)"
                echo "DFS: Deep first (Stack)"
                ;;
            *)
                echo "📚 Gunakan: openclaw, explain [topik]"
                ;;
        esac
        ;;
        
    "help"|"--help"|"-h")
        show_help
        ;;
        
    *)
        echo "🧠 OSNK Trainer"
        echo "Ketik: openclaw, help"
        ;;
esac