# Docker Commands

## Development Container

### Create Image
```
docker build -t fieldprime-swift-dev -f server-swift/FieldPrimeServer/Dockerfile .
```

### Create Container
```bash
docker run --rm -it --name fp-dev \
    -v "$PWD/server-swift/FieldPrimeServer:/workspace/server-swift/FieldPrimeServer" \
    -v "$PWD/shared:/workspace/shared" \
    -v "$PWD/sqlite-data:/app/data" \
    -w /workspace/server-swift/FieldPrimeServer \
    -e SQLITE_PATH=/app/data/fieldprime.db \
    -p 8080:8080 fieldprime-swift-dev
```

### Build App
```
swift build
```

### Run App
```
.build/debug/App serve --hostname 0.0.0.0 --port 8080
```

### Smoke test
```
curl -i http://localhost:8080/

curl -i http://localhost:8080/hello
```
