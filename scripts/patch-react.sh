# git clone https://github.com/facebook/react.git
# (cd react && yarn && npm run build)
(cd node_modules && rm -rf react react-art react-dom react-noop-renderer react-test-renderer)
mv ./react/build/packages/* ./node_modules/
