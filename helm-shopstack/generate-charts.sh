#!/bin/bash

# Service configurations
declare -A services=(
    ["cart"]="nodejs|8080|REDIS_HOST=redis,CATALOGUE_HOST=catalogue,CART_SERVER_PORT=8080,INSTANA_AUTO_PROFILE=true"
    ["catalogue"]="nodejs|8080|MONGO_URL=mongodb://mongodb:27017/catalogue,GO_SLOW=0,CATALOGUE_SERVER_PORT=8080,INSTANA_AUTO_PROFILE=true"
    ["user"]="nodejs|8080|REDIS_HOST=redis,MONGO_URL=mongodb://mongodb:27017/users,USER_SERVER_PORT=8080,INSTANA_AUTO_PROFILE=true"
    ["payment"]="python|8080|CART_HOST=cart,USER_HOST=user,PAYMENT_GATEWAY=https://paypal.com/,PAYMENT_DELAY_MS=0,SHOP_PAYMENT_PORT=8080,INSTANA_SERVICE_NAME=payment"
    ["shipping"]="java|8080|CART_ENDPOINT=cart:8080,DB_HOST=mysql"
    ["dispatch"]="go|8080|AMQP_HOST=rabbitmq,DISPATCH_ERROR_PERCENT=0"
    ["ratings"]="php|8080|APP_ENV=production"
    ["web"]="nginx|8080|CATALOGUE_HOST=catalogue,USER_HOST=user,CART_HOST=cart,SHIPPING_HOST=shipping,PAYMENT_HOST=payment,RATINGS_HOST=ratings"
    ["mysql"]="mysql|3306|MYSQL_ALLOW_EMPTY_PASSWORD=yes,MYSQL_DATABASE=cities,MYSQL_USER=shipping,MYSQL_PASSWORD=secret"
    ["mongo"]="mongo|27017|"
)

# Create charts for each service
for service in "${!services[@]}"; do
    config="${services[$service]}"
    IFS='|' read -r lang port env_vars <<< "$config"
    
    echo "Creating Helm chart for $service..."
    
    # Create Chart.yaml
    cat > "$service/Chart.yaml" << EOF
apiVersion: v2
name: $service
description: A Helm chart for Kubernetes $service Service

type: application

version: 0.1.0
appVersion: "1.0.0"
EOF

    # Create values.yaml
    cat > "$service/values.yaml" << EOF
defaults:
  namespace:
    name: shopstack
    enabled: false
  labels: $service
  managedBy: Helm
  annotations:
    lang: $lang

# DEPLOYMENT CONFIGURATION
deploy:
  replicaCount: 1
  image:
    repository: ghcr.io/shopstack/shopstack-$service
    tag: latest
    pullPolicy: IfNotPresent
  affinity:
    nodeAffinity:
      key: app
      operator: In
      values: $service
  strategy:
    type: RollingUpdate
    maxSurge: 50%
    maxUnavailable: 0
  resources:
    requests:
      memory: "200Mi" 
      cpu: "100m"
    limits:
      memory: "500Mi"
      cpu: "200m"
  restartPolicy: Always
  readinessProbe:
    enabled: true
    path: /health
    scheme: HTTP
    initialDelaySeconds: 10
    periodSeconds: 5
    failureThreshold: 3
    successThreshold: 1
  livenessProbe:
    enabled: true
    path: /health
    scheme: HTTP
    initialDelaySeconds: 30
    periodSeconds: 10
    failureThreshold: 3
    successThreshold: 1
  tolerations:
    key: app
    operator: Equal
    value: $service
EOF

    # Add environment variables if they exist
    if [ -n "$env_vars" ]; then
        cat >> "$service/values.yaml" << EOF
  env:
EOF
        IFS=',' read -ra vars <<< "$env_vars"
        for var in "${vars[@]}"; do
            IFS='=' read -r key value <<< "$var"
            cat >> "$service/values.yaml" << EOF
    - name: $key
      value: "$value"
EOF
        done
    fi

    # Add service configuration
    cat >> "$service/values.yaml" << EOF

# SERVICE CONFIGURATION
service:
  type: ClusterIP
  ports:
    http:
      name: http
      protocol: TCP
      port: $port
      targetPort: $port

# INGRESS CONFIGURATION
ingress:
  enabled: true
  ingressClassName: nginx
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
  host: $service.shopstack.local
  path: /
  pathType: Prefix

# HORIZONTAL POD AUTOSCALER CONFIGURATION
hpa:
  enabled: true
  maxReplicas: 3
  minReplicas: 1
  cpu:
    metrics:
      resourceName: cpu
      averageUtilization: 70
      type: Utilization
  behavior:
    scaleDown:
      policies:
        periodSeconds: 15
        type: Percent
        value: 100
      selectPolicy: Min
      stabilizationWindowSeconds: 180
    scaleUp:
      policies:
        periodSeconds: 15
        type: Percent
        value: 30
      selectPolicy: Min
      stabilizationWindowSeconds: 500

# SECRET CONFIGURATION
secret:
  enabled: false
  name: $service-secret
  type: Opaque
  data: ""

# POD DISRUPTION BUDGET CONFIGURATION
pdb:
  enabled: true
  minAvailable: 1

configMap:
  enabled: false
EOF

    # Copy templates from cart service and replace service name
    cp -r cart/templates/* "$service/templates/"
    
    # Update _helpers.tpl for the specific service
    sed -i "s/cart/$service/g" "$service/templates/_helpers.tpl"
    sed -i "s/Cart/${service^}/g" "$service/templates/_helpers.tpl"
    
    echo "Created Helm chart for $service"
done

echo "All Helm charts created successfully!"
