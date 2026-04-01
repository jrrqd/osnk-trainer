#!/bin/bash

# OSNK Trainer Skill - Main Script
# OSK/OSNK Practice with Performance Tracking

COMMAND="$1"
shift

# Dynamic path detection
if [ -n "$OPENCLAW_WORKSPACE" ]; then
    DATA_DIR="$OPENCLAW_WORKSPACE/memory"
    KB_DIR="$OPENCLAW_WORKSPACE/knowledge"
elif [ -d "/root/.openclaw/workspace/memory" ]; then
    DATA_DIR="/root/.openclaw/workspace/memory"
    KB_DIR="/root/.openclaw/workspace/knowledge"
else
    DATA_DIR="./memory"
    KB_DIR="./knowledge"
fi

mkdir -p "$DATA_DIR"

# Files
STATS_FILE="$DATA_DIR/osnk-stats.json"
PROGRESS_FILE="$DATA_DIR/osnk-progress.json"
CONFIG_FILE="$DATA_DIR/osnk-config.json"

# Question bank path
# KB_DIR set above

init_stats() {
    if [ ! -f "$STATS_FILE" ]; then
        echo '{"total_attempted":0,"correct":0,"wrong":0,"by_category":{},"by_year":{},"sessions":0,"last_session":""}' > "$STATS_FILE"
    fi
}

get_random_question() {
    year="$1"
    category="$2"
    
    if [ -z "$year" ]; then
        # Get random file
        local files=$(find "$KB_DIR" -name "osk-*.md" -o -name "osnk-*.md" | shuf | head -3)
        for f in $files; do
            grep -A10 "^## " "$f" | head -20 || echo "No questions found"
        done
    else
        if [ -f "$KB_DIR/osk-$year.md" ]; then
            shuf -n 1 "$KB_DIR/osk-$year.md" | head -15
        elif [ -f "$KB_DIR/osnk-$year.md" ]; then
            shuf -n 1 "$KB_DIR/osnk-$year.md" | head -15
        else
            echo "Year $year not found in question bank"
        fi
    fi
}

show_stats() {
    init_stats
    local total=$(cat "$STATS_FILE" | grep -o '"total_attempted":[0-9]*' | cut -d: -f2)
    local correct=$(cat "$STATS_FILE" | grep -o '"correct":[0-9]*' | cut -d: -f2)
    local wrong=$(cat "$STATS_FILE" | grep -o '"wrong":[0-9]*' | cut -d: -f2)
    local sessions=$(cat "$STATS_FILE" | grep -o '"sessions":[0-9]*' | cut -d: -f2)
    
    if [ -z "$total" ] || [ "$total" = "0" ]; then
        echo "📊 Your OSNK Training Stats"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "No training sessions yet!"
        echo ""
        echo "Start training: openclaw, give me 5 questions"
    else
        local accuracy=$((correct * 100 / total))
        echo "📊 Your OSNK Training Stats"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📝 Total Questions: $total"
        echo "✅ Correct: $correct"
        echo "❌ Wrong: $wrong"
        echo "📈 Accuracy: $accuracy%"
        echo "🎯 Sessions: $sessions"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    fi
}

show_help() {
    echo "🧠 OSNK Trainer - Olympic CS Training"
    echo ""
    echo "📝 Practice Questions:"
    echo "  openclaw, give me 5 questions"
    echo "  openclaw, 10 graph theory questions"
    echo "  openclaw, random OSK 2018 questions"
    echo ""
    echo "⏱️ Speed Run:"
    echo "  openclaw, start speed run 30 minutes"
    echo "  openclaw, 20 min speed run"
    echo ""
    echo "📊 Performance:"
    echo "  openclaw, show my stats"
    echo "  openclaw, my progress"
    echo "  openclaw, weak areas"
    echo ""
    echo "🎓 Mentoring:"
    echo "  openclaw, explain dynamic programming"
    echo "  openclaw, what is BFS?"
    echo "  openclaw, hint for question 3"
    echo ""
    echo "📚 Categories:"
    echo "  DP, Graph, Combinatorics, Number Theory"
    echo "  Boolean Algebra, Algorithm Analysis, Data Structures"
}

case "$COMMAND" in
    "stats"|"performance"|"my-stats")
        show_stats
        ;;
        
    "random"|"questions"|"give")
        num="${1:-5}"
        topic="$*"
        
        echo "🎯 Here's your $num random questions:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        for i in $(seq 1 $num); do
            echo ""
            echo "Question $i:"
            get_random_question "" "" | head -8
        done
        echo ""
        echo "Type: openclaw, check answer [question] [your_answer]"
        ;;
        
    "speed"|"speedrun"|"timed")
        local duration="${1:-30}"
        echo "⏱️ Speed Run Started!"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "Duration: $duration minutes"
        echo "Target: Answer as many as possible"
        echo "Scoring: +4 correct, -1 wrong"
        echo ""
        echo "Ready? Answer these questions:"
        get_random_question "" "" | head -10
        ;;
        
    "explain"|"what"|"define")
        topic="$*"
        case "$topic" in
            *dynamic*|*dp*)
                echo "📖 Dynamic Programming (DP)"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "DP is an optimization technique that solves"
                echo "problems by breaking them into overlapping"
                echo "subproblems and storing solutions."
                echo ""
                echo "Key concepts:"
                echo "- Memoization (top-down)"
                echo "- Tabulation (bottom-up)"
                echo "- State transition formula"
                ;;
            *graph*|*bfs*|*dfs*)
                echo "📖 Graph Traversal"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "BFS (Breadth-First Search): Level by level"
                echo "DFS (Depth-First Search): Go deep first"
                echo ""
                echo "BFS: Queue-based, shortest path"
                echo "DFS: Stack-based, cycle detection"
                ;;
            *combinatorics*)
                echo "📖 Combinatorics"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "Counting techniques:"
                echo "- Permutations: arrangement order matters"
                echo "- Combinations: selection only"
                echo "- P(n,r) = n!/(n-r)!"
                echo "- C(n,r) = n!/r!(n-r)!"
                ;;
            *)
                echo "📖 Topic: $topic"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "Use: openclaw, explain [topic]"
                echo "Available: DP, Graph, Combinatorics, etc."
                ;;
        esac
        ;;
        
    "help"|"--help"|"-h")
        show_help
        ;;
        
    *)
        echo "🧠 OSNK Trainer"
        echo "Usage: openclaw, [command]"
        echo ""
        echo "Try: openclaw, help"
        echo "Or:   openclaw, give me 5 questions"
        ;;
esac