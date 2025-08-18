ipynb() {
    python -m jupyter_ascending.scripts.make_pair --base "$*"
}

yad() {
    yarn add "$*" --dev
}

ya() {
    yarn add "$*"
}

ndc() {
    rm -r -f ./docs/$1
    mkdir ./docs/$1
    depcruise --include-only "^src" -x "^src/store" -v -T dot src | dot -T svg | depcruise-wrap-stream-in-html > ./docs/$1/dep-graph-reduced.html
    depcruise -v -T dot | dot -T svg | depcruise-wrap-stream-in-html > ./docs/$1/dep-graph-full.html
    depcruise src --output-type dot | dot -T svg > ./docs/$1/dep-graph-full.svg
    dependency-cruise --validate --output-type err-html -f ./docs/$1/dep-report.html src 
    depcruise src --include-only "^src" --config --output-type json > ./docs/$1/dep-graph-full.json
    depcruise src --include-only "^src" --config --output-type archi | dot -T svg > ./docs/$1/dep-graph-archi.svg
}

clean_monorepo() {
  echo "🧹 Cleaning monorepo..."
  
  # Remove all node_modules directories
  echo "📦 Removing node_modules directories..."
  find . -name "node_modules" -type d -prune -exec rm -rf "{}" + || echo "⚠️ Error removing node_modules"
  
  # Remove all pnpm-lock.yaml files
  echo "🔒 Removing pnpm-lock.yaml files..."
  find . -name "pnpm-lock.yaml" -type f -exec rm -f {} \; || echo "⚠️ Error removing pnpm-lock.yaml files"
  
  # Remove .pnpm-store directories (if using local store)
  echo "🏪 Removing .pnpm-store directories..."
  find . -name ".pnpm-store" -type d -prune -exec rm -rf "{}" + || echo "⚠️ Error removing .pnpm-store"
  
  # Remove package.json backup files
  echo "🗄️ Removing package backup files..."
  find . -name "package.json.orig" -o -name "package.json.bak" -type f -exec rm -f {} \; || echo "⚠️ Error removing backup files"
  
  # Clean dist/build directories
  echo "🏗️ Removing dist/build directories..."
  find . -name "dist" -o -name "build" -type d -prune -exec rm -rf "{}" + || echo "⚠️ Error removing dist/build"
  
  # Clear pnpm cache
  echo "🧽 Clearing pnpm store cache..."
  pnpm store prune || echo "⚠️ Error clearing pnpm cache"
  
  echo "✨ Cleanup complete!"
}

initgo() {
    go mod init github.com/thevetat/"$*"
}

newnuxt() {
    pnpm dlx nuxi@latest init "$*"
}