# Shopstack Microservices Helm Charts

This repository contains Helm charts for deploying the Shopstack microservices architecture on Kubernetes.

## 📁 Available Charts

Each microservice has its own dedicated Helm chart with service-specific configurations:

### 🛒 **cart**
- **Language**: Node.js
- **Port**: 8080
- **Environment Variables**:
  - `REDIS_HOST=redis`
  - `CATALOGUE_HOST=catalogue`
  - `CART_SERVER_PORT=8080`
  - `INSTANA_AUTO_PROFILE=true`

### 📚 **catalogue**
- **Language**: Node.js
- **Port**: 8080
- **Environment Variables**:
  - `MONGO_URL=mongodb://mongodb:27017/catalogue`
  - `GO_SLOW=0`
  - `CATALOGUE_SERVER_PORT=8080`
  - `INSTANA_AUTO_PROFILE=true`

### 👤 **user**
- **Language**: Node.js
- **Port**: 8080
- **Environment Variables**:
  - `REDIS_HOST=redis`
  - `MONGO_URL=mongodb://mongodb:27017/users`
  - `USER_SERVER_PORT=8080`
  - `INSTANA_AUTO_PROFILE=true`

### 💳 **payment**
- **Language**: Python
- **Port**: 8080
- **Environment Variables**:
  - `CART_HOST=cart`
  - `USER_HOST=user`
  - `PAYMENT_GATEWAY=https://paypal.com/`
  - `PAYMENT_DELAY_MS=0`
  - `SHOP_PAYMENT_PORT=8080`
  - `INSTANA_SERVICE_NAME=payment`

### 🚚 **shipping**
- **Language**: Java
- **Port**: 8080
- **Environment Variables**:
  - `CART_ENDPOINT=cart:8080`
  - `DB_HOST=mysql`

### 📦 **dispatch**
- **Language**: Go
- **Port**: 8080
- **Environment Variables**:
  - `AMQP_HOST=rabbitmq`
  - `DISPATCH_ERROR_PERCENT=0`

### ⭐ **ratings**
- **Language**: PHP
- **Port**: 8080
- **Environment Variables**:
  - `APP_ENV=production`

### 🌐 **web**
- **Language**: Nginx
- **Port**: 8080
- **Environment Variables**:
  - `CATALOGUE_HOST=catalogue`
  - `USER_HOST=user`
  - `CART_HOST=cart`
  - `SHIPPING_HOST=shipping`
  - `PAYMENT_HOST=payment`
  - `RATINGS_HOST=ratings`

### 🗄️ **mysql**
- **Language**: MySQL
- **Port**: 3306
- **Environment Variables**:
  - `MYSQL_ALLOW_EMPTY_PASSWORD=yes`
  - `MYSQL_DATABASE=cities`
  - `MYSQL_USER=shipping`
  - `MYSQL_PASSWORD=secret`

### 🍃 **mongo**
- **Language**: MongoDB
- **Port**: 2706
- **Environment Variables**: None

## 🚀 Quick Start

### Install a Single Service

```bash
# Install the cart service
helm install cart ./cart

# Install the catalogue service
helm install catalogue ./catalogue

# Install all services
for service in cart catalogue user payment shipping dispatch ratings web mysql mongo; do
  helm install $service ./$service
done
```

### Install with Custom Values

```bash
# Install with custom values file
helm install cart ./cart -f values-custom.yaml

# Install with specific image tag
helm install cart ./cart --set deploy.image.tag=v1.2.3

# Install with custom replica count
helm install cart ./cart --set deploy.replicaCount=3
```

### Upgrade a Service

```bash
helm upgrade cart ./cart
```

### Uninstall a Service

```bash
helm uninstall cart
```

## ⚙️ Configuration

Each chart includes the following configurable sections:

- **deploy**: Deployment configuration (replicas, image, resources, probes)
- **service**: Service configuration (type, ports)
- **ingress**: Ingress configuration (host, path, annotations)
- **hpa**: Horizontal Pod Autoscaler configuration
- **secret**: Secret configuration
- **pdb**: Pod Disruption Budget configuration
- **configMap**: ConfigMap configuration

### Key Configuration Options

```yaml
# Deployment
deploy:
  replicaCount: 1
  image:
    repository: ghcr.io/shopstack/shopstack-cart
    tag: latest
  resources:
    requests:
      memory: "200Mi"
      cpu: "100m"
    limits:
      memory: "500Mi"
      cpu: "200m"

# Service
service:
  type: ClusterIP
  ports:
    http:
      port: 8080
      targetPort: 8080

# Ingress
ingress:
  enabled: true
  host: cart.shopstack.local
  path: /

# HPA
hpa:
  enabled: true
  maxReplicas: 3
  minReplicas: 1
  cpu:
    metrics:
      averageUtilization: 70
```

## 🔧 Customization

### Environment-Specific Values

Create separate values files for different environments:

```bash
# values-dev.yaml
deploy:
  replicaCount: 1
  resources:
    requests:
      memory: "100Mi"
      cpu: "50m"

# values-prod.yaml
deploy:
  replicaCount: 3
  resources:
    requests:
      memory: "500Mi"
      cpu: "200m"
```

### Custom Ingress Configuration

```yaml
ingress:
  enabled: true
  ingressClassName: alb
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: instance
  host: cart.yourdomain.com
  path: /
```

## 📊 Monitoring & Observability

All charts include:

- **Health Checks**: Readiness and liveness probes
- **Resource Limits**: CPU and memory requests/limits
- **Auto-scaling**: Horizontal Pod Autoscaler support
- **Labels**: Standardized labels for monitoring
- **Annotations**: Service-specific annotations

## 🔒 Security

- **Pod Security Context**: Configurable security contexts
- **Resource Limits**: Prevent resource exhaustion
- **Network Policies**: Can be added via values
- **Secrets Management**: Built-in secret support

## 📝 Examples

### Deploy with Custom Resources

```bash
helm install cart ./cart \
  --set deploy.resources.requests.memory=512Mi \
  --set deploy.resources.requests.cpu=250m \
  --set deploy.resources.limits.memory=1Gi \
  --set deploy.resources.limits.cpu=500m
```

### Deploy with Custom Environment

```bash
helm install cart ./cart \
  --set deploy.env[0].name=REDIS_HOST \
  --set deploy.env[0].value=redis-cluster \
  --set deploy.env[1].name=CATALOGUE_HOST \
  --set deploy.env[1].value=catalogue-cluster
```

### Deploy with Auto-scaling Disabled

```bash
helm install cart ./cart --set hpa.enabled=false
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `helm template`
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.
