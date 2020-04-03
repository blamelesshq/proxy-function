# Lambda function for Prometheus

You need to do for locally run:
1. Open `main.go` and uncomment some lines;
2. Create `.env` file from `.env_template`:
```bash
  cp .env_template .env
```
3. Set actuality values;
4. Run command from `Makefile`:
```bash
make
```

Build the code for deployment to `AWS lambda`:
1. Set environment variables for your lambda function in AWS console(or use CLI):
```bash
export PROMETHEUS_URL=<PROMETHEUS_URL>
export PROMETHEUS_LOGIN=<PROMETHEUS_LOGIN>
export PROMETHEUS_PASSWORD=<PROMETHEUS_PASSWORD>
```
2. Run command from `Makefile`:
```bash
make zip-aws
```
3. Deploy `function.zip` to `AWS`.
