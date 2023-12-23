set -e

npm install

npm run build

cd dist

git init
git add -A
git commit -m 'v1.0'

git push -f git@github.com:Aleksis99999/Aleksis99999.github.io.git master:gh-pages

cd -