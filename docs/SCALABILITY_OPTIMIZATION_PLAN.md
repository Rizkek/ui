# 🚀 Scalability Optimization Plan - Handling 10k-100k Concurrent Clients

## 📊 **Current Load Estimation**

| Clients | Requests/5s | Requests/sec | Daily Requests | Monthly Requests |
|---------|-------------|--------------|----------------|------------------|
| 10,000  | 10,000      | 2,000        | 172.8M         | 5.18B            |
| 50,000  | 50,000      | 10,000       | 864M           | 25.9B            |
| 100,000 | 100,000     | 20,000       | 1.73B          | 51.8B            |

**Current Problem:** 
- Single Go server cannot handle 20k req/s
- Python ML service is synchronous bottleneck
- Firestore writes will hit quota limits
- No caching, no load balancing, no rate limiting

---

## 🎯 **Optimization Categories**

1. ⚡ **Architecture Changes** (High Impact)
2. 🔄 **Algorithm & Logic Optimization** (Medium Impact)
3. 💾 **Database & Caching Strategy** (High Impact)
4. 🌐 **Infrastructure & Deployment** (Critical)
5. 📊 **Monitoring & Auto-Scaling** (Essential)

---

## ⚡ **1. ARCHITECTURE CHANGES**

### **1.1 Implement Microservices with Message Queue**

**Current Flow:**
```
Flutter App → Go API → Python ML → Firestore
   (sync)      (sync)     (sync)      (sync)
```

**Optimized Flow:**
```
Flutter App → API Gateway → Load Balancer
                              ↓
                    Go API Instances (x10-50)
                              ↓
                    Redis Queue (RabbitMQ/Redis Stream)
                              ↓
                    Python ML Workers (x20-100)
                              ↓
                    Bulk Write Service → Firestore
```

**Benefits:**
- ✅ Decouple API from ML processing
- ✅ Horizontal scaling of ML workers
- ✅ Non-blocking API responses (async processing)
- ✅ Retry mechanism for failed jobs
- ✅ Rate limiting per user

**Implementation Priority:** 🔴 **CRITICAL**

**Estimated Impact:** **10-50x throughput increase**

---

### **1.2 Switch to Asynchronous Processing**

**Before:**
```go
// detectnsfw.go (CURRENT - BLOCKING)
func DetectNSFWHandler(db *firestore.Client) gin.HandlerFunc {
    return func(c *gin.Context) {
        // 1. Parse image (50ms)
        // 2. Forward to Python (500-2000ms) ← BOTTLENECK
        // 3. Classify result (10ms)
        // 4. Update Firestore (100ms)
        // Total: 660-2160ms per request
    }
}
```

**After (Async with Queue):**
```go
// NEW DESIGN - NON-BLOCKING
func DetectNSFWHandler(redisClient *redis.Client, db *firestore.Client) gin.HandlerFunc {
    return func(c *gin.Context) {
        // 1. Parse image (50ms)
        // 2. Push to Redis Queue (5ms)
        // 3. Return jobId immediately (5ms)
        // Total: 60ms per request ← 10-30x FASTER!
        
        c.JSON(200, gin.H{
            "status": "queued",
            "jobId": uuid.New().String(),
            "estimatedTime": "3-10s", // depends on queue size
        })
    }
}
```

**Background Worker:**
```go
// worker.go (runs separately)
func NSFWWorker(redisClient *redis.Client, db *firestore.Client) {
    for {
        job := redisClient.BLPop("nsfw_queue", 0) // blocking pop
        
        // Process ML detection
        result := callPythonService(job.Image)
        
        // Update Firestore
        updateStatistics(db, job.Email, result)
        
        // Store result for client polling
        redisClient.Set("result:"+job.JobId, result, 5*time.Minute)
    }
}
```

**Implementation Priority:** 🔴 **CRITICAL**

**Estimated Impact:** **30x response time reduction**

---

### **1.3 Add API Gateway with Rate Limiting**

**Tools:** Kong, Nginx, Traefik, or AWS API Gateway

**Features Needed:**
- ✅ Rate limiting: 1 request per 5 seconds per user (no cheating timer)
- ✅ Request throttling: 100 req/s per IP
- ✅ JWT validation (offload from Go service)
- ✅ Request/response caching
- ✅ DDoS protection

**Example (Kong config):**
```yaml
plugins:
  - name: rate-limiting
    config:
      second: 1
      minute: 12
      hour: 720
      policy: local
      fault_tolerant: true
      hide_client_headers: false
      redis_host: redis.local
      
  - name: request-size-limiting
    config:
      allowed_payload_size: 10 # 10MB max screenshot
```

**Implementation Priority:** 🔴 **CRITICAL**

**Estimated Impact:** Block 50-70% spam/invalid requests

---

## 🔄 **2. ALGORITHM & LOGIC OPTIMIZATION**

### **2.1 Implement Smart Detection (Skip Duplicate Frames)**

**Problem:** User might be on same screen for 15-30 seconds = 3-6 identical screenshots

**Solution: Image Perceptual Hashing**

```go
// Add to detectnsfw.go
import "github.com/corona10/goimagehash"

func DetectNSFWHandler(redisClient *redis.Client) gin.HandlerFunc {
    return func(c *gin.Context) {
        image := parseImage(c)
        
        // Generate perceptual hash (pHash)
        hash, _ := goimagehash.PerceptionHash(image)
        hashStr := hash.ToString()
        
        // Check if similar image was processed recently (last 30s)
        cachedResult := redisClient.Get("hash:"+hashStr)
        if cachedResult != nil {
            // Return cached result without ML call
            c.JSON(200, cachedResult)
            return
        }
        
        // Process new image
        result := processMLDetection(image)
        
        // Cache result by hash for 30 seconds
        redisClient.Set("hash:"+hashStr, result, 30*time.Second)
        
        c.JSON(200, result)
    }
}
```

**Implementation Priority:** 🟡 **HIGH**

**Estimated Impact:** Reduce 40-60% redundant ML calls

---

### **2.2 Client-Side Rate Limiting (Flutter)**

**Current Problem:** Timer runs even if app is in background

**Solution:**
```dart
// auto_screenshot_service.dart
Timer? _timer;
AppLifecycleState? _lastState;

void startMonitoring() {
  // Add lifecycle listener
  WidgetsBinding.instance.addObserver(this);
  
  _timer = Timer.periodic(Duration(seconds: 5), (timer) {
    // SKIP if app in background
    if (_lastState != AppLifecycleState.resumed) {
      print('⏸️ Skipping capture - app in background');
      return;
    }
    
    // SKIP if user on home screen (not in monitored app)
    String currentApp = await getCurrentApp();
    if (!monitoredApps.contains(currentApp)) {
      print('⏸️ Skipping capture - not in monitored app');
      return;
    }
    
    // SKIP if same app and screen for >15s (use screen hash)
    if (isSameScreenAsLastCapture()) {
      print('⏸️ Skipping capture - same screen');
      return;
    }
    
    _captureAndSend();
  });
}

@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  _lastState = state;
  if (state == AppLifecycleState.paused) {
    print('📱 App paused - timer continues but captures skipped');
  }
}
```

**Implementation Priority:** 🟢 **MEDIUM**

**Estimated Impact:** Reduce 30-50% unnecessary captures

---

### **2.3 Dynamic Interval Adjustment**

**Concept:** Increase interval if content is safe, decrease if risky

```dart
// auto_screenshot_service.dart
class DynamicIntervalService {
  int _currentInterval = 5; // start with 5 seconds
  int _consecutiveSafe = 0;
  
  void adjustInterval(int nsfwLevel) {
    if (nsfwLevel == 0) {
      _consecutiveSafe++;
      
      // After 6 safe screenshots (30s safe), slow down to 10s
      if (_consecutiveSafe >= 6) {
        _currentInterval = 10;
      }
      
      // After 12 safe (2 minutes safe), slow down to 15s
      if (_consecutiveSafe >= 12) {
        _currentInterval = 15;
      }
    } else {
      // Reset to 5s if NSFW detected
      _consecutiveSafe = 0;
      _currentInterval = 5;
    }
    
    // Restart timer with new interval
    _restartTimer();
  }
}
```

**Implementation Priority:** 🟢 **MEDIUM**

**Estimated Impact:** Reduce 20-40% requests during safe periods

---

## 💾 **3. DATABASE & CACHING STRATEGY**

### **3.1 Implement Multi-Layer Caching**

```
┌────────────────────────────────────────────────┐
│  Layer 1: In-Memory Cache (Go service)        │
│  - LRU cache for ML results (10k entries)     │
│  - TTL: 30 seconds                             │
│  - Hit rate: 40-60%                            │
└────────────────┬───────────────────────────────┘
                 │ (miss)
                 ▼
┌────────────────────────────────────────────────┐
│  Layer 2: Redis Cache (shared)                │
│  - Image hash → Result mapping                │
│  - User profile cache                          │
│  - TTL: 5 minutes                              │
│  - Hit rate: 70-85%                            │
└────────────────┬───────────────────────────────┘
                 │ (miss)
                 ▼
┌────────────────────────────────────────────────┐
│  Layer 3: Firestore (persistent)              │
│  - Full statistics                             │
│  - Historical data                             │
│  - Read rate: 10-15%                           │
└────────────────────────────────────────────────┘
```

**Implementation:**
```go
// cache/cache.go
type CacheLayer struct {
    local  *ristretto.Cache  // in-memory
    redis  *redis.Client     // distributed
    db     *firestore.Client // persistent
}

func (c *CacheLayer) GetMLResult(imageHash string) (*Result, error) {
    // Try local cache first
    if val, found := c.local.Get(imageHash); found {
        return val.(*Result), nil
    }
    
    // Try Redis
    val, err := c.redis.Get("ml:" + imageHash).Result()
    if err == nil {
        result := parseResult(val)
        c.local.Set(imageHash, result, 1) // warm local cache
        return result, nil
    }
    
    // Cache miss - need to compute
    return nil, ErrCacheMiss
}
```

**Implementation Priority:** 🔴 **CRITICAL**

**Estimated Impact:** 70-85% request reduction to Firestore

---

### **3.2 Batch Firestore Writes**

**Current:** 1 write per detection (expensive, slow)

**Optimized:** Batch writes every 10 seconds

```go
// batch_writer.go
type BatchWriter struct {
    db     *firestore.Client
    buffer []StatUpdate
    mu     sync.Mutex
    ticker *time.Ticker
}

func NewBatchWriter(db *firestore.Client) *BatchWriter {
    bw := &BatchWriter{
        db:     db,
        buffer: make([]StatUpdate, 0, 1000),
        ticker: time.NewTicker(10 * time.Second),
    }
    
    go bw.flushLoop()
    return bw
}

func (bw *BatchWriter) Add(update StatUpdate) {
    bw.mu.Lock()
    bw.buffer = append(bw.buffer, update)
    
    // Force flush if buffer full
    if len(bw.buffer) >= 500 {
        go bw.flush()
    }
    bw.mu.Unlock()
}

func (bw *BatchWriter) flush() {
    bw.mu.Lock()
    defer bw.mu.Unlock()
    
    if len(bw.buffer) == 0 {
        return
    }
    
    // Aggregate updates (merge multiple updates for same user+date)
    aggregated := bw.aggregate(bw.buffer)
    
    // Batch write to Firestore (max 500 per batch)
    batch := bw.db.Batch()
    for _, update := range aggregated {
        docRef := bw.db.Collection("nsfw_stats").Doc(update.DocID)
        batch.Set(docRef, update.Data, firestore.MergeAll)
    }
    
    batch.Commit(context.Background())
    bw.buffer = bw.buffer[:0] // clear buffer
}

func (bw *BatchWriter) flushLoop() {
    for range bw.ticker.C {
        bw.flush()
    }
}
```

**Implementation Priority:** 🟡 **HIGH**

**Estimated Impact:** 90% reduction in Firestore write operations

---

### **3.3 Use Time-Series Database for Statistics**

**Problem:** Firestore is expensive for time-series data

**Solution:** Use InfluxDB or TimescaleDB (Postgres extension)

**Comparison:**

| Feature              | Firestore       | InfluxDB         | TimescaleDB      |
|----------------------|-----------------|------------------|------------------|
| Write throughput     | 10k writes/sec  | 1M points/sec    | 100k rows/sec    |
| Cost (1B writes)     | $1,800          | $200 (self-host) | $100 (self-host) |
| Query performance    | Medium          | Excellent        | Excellent        |
| Aggregation          | Limited         | Built-in         | SQL (powerful)   |
| Auto-downsampling    | No              | Yes              | Yes              |

**Recommended:** TimescaleDB (Postgres-based, familiar SQL)

```sql
-- Schema design
CREATE TABLE nsfw_detections (
  time        TIMESTAMPTZ NOT NULL,
  user_id     TEXT NOT NULL,
  application TEXT NOT NULL,
  nsfw_level  INTEGER NOT NULL,
  device_id   TEXT
);

-- Convert to hypertable (time-series optimization)
SELECT create_hypertable('nsfw_detections', 'time');

-- Auto-aggregate old data (keep 1-hour granularity after 7 days)
CREATE MATERIALIZED VIEW nsfw_detections_hourly
WITH (timescaledb.continuous) AS
SELECT 
  time_bucket('1 hour', time) AS hour,
  user_id,
  application,
  COUNT(*) as total_detections,
  SUM(CASE WHEN nsfw_level > 0 THEN 1 ELSE 0 END) as nsfw_count
FROM nsfw_detections
GROUP BY hour, user_id, application;

-- Retention policy (delete raw data after 30 days)
SELECT add_retention_policy('nsfw_detections', INTERVAL '30 days');
```

**Implementation Priority:** 🟡 **HIGH** (for cost reduction)

**Estimated Impact:** 80% cost reduction, 5x faster queries

---

## 🌐 **4. INFRASTRUCTURE & DEPLOYMENT**

### **4.1 Horizontal Scaling Architecture**

```
                    Internet
                       ↓
        ┌──────────────────────────┐
        │   CloudFlare CDN/WAF     │ ← DDoS protection
        └──────────┬───────────────┘
                   ↓
        ┌──────────────────────────┐
        │   Load Balancer (L7)     │
        │   (ALB/Nginx/HAProxy)    │
        └──────────┬───────────────┘
                   ↓
     ┌─────────────┴─────────────┐
     ↓                           ↓
┌─────────┐                 ┌─────────┐
│ Go API  │                 │ Go API  │
│ Pod 1   │  ... (x10-50)   │ Pod 50  │
└────┬────┘                 └────┬────┘
     │                           │
     └─────────────┬─────────────┘
                   ↓
        ┌──────────────────────────┐
        │   Redis Cluster          │
        │   (Queue + Cache)        │
        └──────────┬───────────────┘
                   ↓
     ┌─────────────┴─────────────┐
     ↓                           ↓
┌──────────┐               ┌──────────┐
│ ML Worker│               │ ML Worker│
│ Python 1 │ ... (x20-100) │ Python N │
└────┬─────┘               └────┬─────┘
     │                           │
     └─────────────┬─────────────┘
                   ↓
        ┌──────────────────────────┐
        │   TimescaleDB Cluster    │
        │   (Primary + Replicas)   │
        └──────────────────────────┘
```

**Scaling Strategy:**

| Component    | Min Instances | Max Instances | Scale Trigger       |
|--------------|---------------|---------------|---------------------|
| Go API       | 5             | 50            | CPU > 70%           |
| ML Workers   | 10            | 100           | Queue depth > 1000  |
| Redis Cache  | 3             | 9             | Memory > 80%        |
| TimescaleDB  | 2             | 5             | Connection pool > 80%|

**Implementation Priority:** 🔴 **CRITICAL**

---

### **4.2 Containerization with Kubernetes**

```yaml
# k8s/api-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: reflvy-api
spec:
  replicas: 10
  selector:
    matchLabels:
      app: reflvy-api
  template:
    metadata:
      labels:
        app: reflvy-api
    spec:
      containers:
      - name: api
        image: reflvy/api:latest
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "1Gi"
            cpu: "1000m"
        env:
        - name: REDIS_URL
          valueFrom:
            secretKeyRef:
              name: redis-secret
              key: url
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: reflvy-api-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: reflvy-api
  minReplicas: 5
  maxReplicas: 50
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

**Implementation Priority:** 🔴 **CRITICAL**

---

### **4.3 ML Service Optimization**

**Current Python Service Issues:**
- Synchronous Flask (single threaded)
- No batch processing
- Loads model on every request (slow cold start)

**Optimized Python Service:**

```python
# ml_service.py
from fastapi import FastAPI
from concurrent.futures import ThreadPoolExecutor
import torch
import asyncio

app = FastAPI()

# Load model once at startup (not per request!)
MODEL = load_nsfw_model()
MODEL.eval()

# Thread pool for CPU-bound operations
executor = ThreadPoolExecutor(max_workers=8)

@app.post("/detect")
async def detect_nsfw(image: UploadFile):
    # Offload to thread pool
    loop = asyncio.get_event_loop()
    result = await loop.run_in_executor(
        executor,
        process_image,
        image
    )
    return result

# Batch endpoint (process multiple images)
@app.post("/detect_batch")
async def detect_batch(images: List[UploadFile]):
    # Process in parallel batches
    tasks = [detect_nsfw(img) for img in images]
    results = await asyncio.gather(*tasks)
    return results
```

**Run with Gunicorn + Uvicorn:**
```bash
gunicorn ml_service:app \
  --workers 4 \
  --worker-class uvicorn.workers.UvicornWorker \
  --bind 0.0.0.0:5000 \
  --timeout 30 \
  --max-requests 1000 \
  --max-requests-jitter 100
```

**Implementation Priority:** 🔴 **CRITICAL**

**Estimated Impact:** 10x ML throughput increase

---

## 📊 **5. MONITORING & AUTO-SCALING**

### **5.1 Comprehensive Monitoring Stack**

**Tools:** Prometheus + Grafana + Loki

**Metrics to Track:**
```
# API Metrics
- request_duration_seconds (histogram)
- request_count_total (counter)
- active_connections (gauge)
- error_rate (counter)

# Queue Metrics
- queue_depth (gauge)
- queue_processing_time (histogram)
- queue_dead_letter_count (counter)

# ML Metrics
- ml_inference_duration (histogram)
- ml_batch_size (histogram)
- gpu_utilization (gauge)

# Database Metrics
- db_query_duration (histogram)
- db_connection_pool_size (gauge)
- cache_hit_rate (gauge)

# Business Metrics
- nsfw_detections_per_level (counter)
- active_users (gauge)
- revenue_per_day (gauge)
```

**Grafana Dashboard Example:**
```json
{
  "dashboard": {
    "title": "Reflvy System Overview",
    "panels": [
      {
        "title": "Requests per Second",
        "targets": ["rate(request_count_total[1m])"]
      },
      {
        "title": "P95 Latency",
        "targets": ["histogram_quantile(0.95, request_duration_seconds)"]
      },
      {
        "title": "Queue Depth",
        "targets": ["queue_depth"],
        "alert": {
          "condition": "queue_depth > 5000",
          "action": "scale_ml_workers"
        }
      }
    ]
  }
}
```

**Implementation Priority:** 🟡 **HIGH**

---

### **5.2 Auto-Scaling Policies**

```yaml
# AWS Auto Scaling Policy Example
ScalingPolicies:
  - PolicyName: ScaleUpOnQueueDepth
    PolicyType: TargetTrackingScaling
    TargetTrackingScalingPolicyConfiguration:
      CustomizedMetricSpecification:
        MetricName: QueueDepth
        Namespace: Reflvy
        Statistic: Average
      TargetValue: 1000.0
      ScaleInCooldown: 300
      ScaleOutCooldown: 60
  
  - PolicyName: ScaleUpOnCPU
    PolicyType: TargetTrackingScaling
    TargetTrackingScalingPolicyConfiguration:
      PredefinedMetricSpecification:
        PredefinedMetricType: ASGAverageCPUUtilization
      TargetValue: 70.0
```

**Implementation Priority:** 🟡 **HIGH**

---

## 💰 **6. COST OPTIMIZATION**

### **6.1 Cost Comparison (100k Users)**

| Component              | Current (Month) | Optimized (Month) | Savings |
|------------------------|-----------------|-------------------|---------|
| Firestore writes       | $18,000         | $2,000            | 89%     |
| Firestore reads        | $3,000          | $300              | 90%     |
| Go API (Cloud Run)     | $5,000          | $3,000 (K8s)      | 40%     |
| Python ML (CPU)        | $8,000          | $4,000 (batch)    | 50%     |
| Redis Cache            | -               | $500              | -       |
| TimescaleDB            | -               | $800              | -       |
| Monitoring             | -               | $200              | -       |
| **TOTAL**              | **$34,000**     | **$10,800**       | **68%** |

---

## 🎯 **7. IMPLEMENTATION ROADMAP**

### **Phase 1: Critical (Week 1-2)** 🔴
- [ ] Setup Redis for caching + queue
- [ ] Implement async processing with job queue
- [ ] Add API Gateway with rate limiting
- [ ] Optimize Python ML service (FastAPI + Gunicorn)
- [ ] Implement image perceptual hashing (skip duplicates)

**Expected Result:** Handle 5k-10k req/s

---

### **Phase 2: High Priority (Week 3-4)** 🟡
- [ ] Implement batch Firestore writes
- [ ] Add multi-layer caching (in-memory + Redis)
- [ ] Setup Kubernetes cluster with auto-scaling
- [ ] Migrate statistics to TimescaleDB
- [ ] Client-side smart capture (skip background/duplicate screens)

**Expected Result:** Handle 15k-20k req/s, 70% cost reduction

---

### **Phase 3: Optimization (Week 5-6)** 🟢
- [ ] Setup monitoring (Prometheus + Grafana)
- [ ] Implement dynamic interval adjustment
- [ ] Add CDN for static assets
- [ ] Setup distributed tracing (Jaeger)
- [ ] Load testing & performance tuning

**Expected Result:** Handle 20k-30k req/s, full observability

---

### **Phase 4: Advanced (Week 7-8)** 🔵
- [ ] Implement ML model optimization (ONNX/TensorRT)
- [ ] Add edge caching (CloudFlare Workers)
- [ ] Implement predictive scaling
- [ ] Add A/B testing framework
- [ ] Setup multi-region deployment

**Expected Result:** Handle 50k+ req/s, <100ms p95 latency

---

## 📈 **Expected Performance Improvements**

| Metric                  | Current    | After Phase 1 | After Phase 2 | After Phase 4 |
|-------------------------|------------|---------------|---------------|---------------|
| Max req/s               | 500        | 10,000        | 20,000        | 50,000        |
| P95 latency             | 2000ms     | 200ms         | 100ms         | 50ms          |
| Concurrent users        | 2,500      | 50,000        | 100,000       | 250,000       |
| Monthly cost (100k users)| $34,000   | $18,000       | $10,800       | $12,000       |
| Cache hit rate          | 0%         | 60%           | 85%           | 90%           |
| Firestore writes/day    | 17.3M      | 10M           | 1.7M          | 1.7M          |

---

## ⚠️ **Critical Warnings**

### **Do NOT do these:**
❌ Keep synchronous ML processing at scale  
❌ Write to Firestore on every detection  
❌ Run single Go instance without load balancer  
❌ Ignore rate limiting (users can spam API)  
❌ Use Flask single-threaded for ML service  
❌ Deploy without monitoring  
❌ Skip caching layer  

### **Must-have for production:**
✅ Redis queue for async processing  
✅ Load balancer with health checks  
✅ Rate limiting (1 req/5s per user)  
✅ Multi-layer caching (70%+ hit rate)  
✅ Batch database writes  
✅ Horizontal auto-scaling  
✅ Comprehensive monitoring & alerting  
✅ Image deduplication (perceptual hashing)  

---

## 🏁 **Quick Start: Minimum Viable Optimization**

**If you only have 1 week, do this:**

1. **Add Redis** (Docker):
   ```bash
   docker run -d -p 6379:6379 redis:alpine
   ```

2. **Implement async queue** (Go):
   ```go
   // Push to queue instead of sync processing
   redisClient.RPush("nsfw_queue", jobData)
   ```

3. **Add rate limiting middleware** (Go):
   ```go
   func RateLimitMiddleware() gin.HandlerFunc {
       limiter := rate.NewLimiter(rate.Every(5*time.Second), 1)
       return func(c *gin.Context) {
           if !limiter.Allow() {
               c.JSON(429, gin.H{"error": "Too many requests"})
               c.Abort()
               return
           }
           c.Next()
       }
   }
   ```

4. **Upgrade Python ML service** (FastAPI):
   ```bash
   pip install fastapi uvicorn gunicorn
   gunicorn ml_service:app --workers 4 --worker-class uvicorn.workers.UvicornWorker
   ```

5. **Add image deduplication** (Go):
   ```bash
   go get github.com/corona10/goimagehash
   ```

**Result:** 10x performance improvement in 1 week

---

## 📚 **References & Tools**

### **Message Queues:**
- Redis Streams (simplest, good for <50k req/s)
- RabbitMQ (reliable, good for <100k req/s)
- Apache Kafka (best for >100k req/s, complex setup)

### **Caching:**
- Ristretto (in-memory Go cache)
- Redis (distributed cache)
- Memcached (alternative to Redis)

### **Monitoring:**
- Prometheus + Grafana (metrics)
- Loki (logs)
- Jaeger (distributed tracing)

### **Load Testing:**
- k6 (modern, easy to use)
- Locust (Python-based)
- Artillery (Node.js-based)

### **Image Hashing:**
- github.com/corona10/goimagehash (Go)
- imagehash (Python)

---

## 🎯 **Conclusion**

**Current capacity:** ~2,500 concurrent users (500 req/s)  
**Target capacity:** 100,000 concurrent users (20,000 req/s)  
**Gap:** **40x scaling needed**

**Key optimizations (priority order):**
1. 🔴 Redis queue + async processing (**10-30x improvement**)
2. 🔴 Rate limiting + API Gateway (**block 50-70% spam**)
3. 🔴 Optimize Python ML service (**10x throughput**)
4. 🟡 Multi-layer caching (**70-85% cache hit rate**)
5. 🟡 Batch Firestore writes (**90% write reduction**)
6. 🟡 Kubernetes auto-scaling (**infinite horizontal scale**)
7. 🟢 Image deduplication (**40-60% request reduction**)
8. 🟢 TimescaleDB migration (**80% cost reduction**)

**Total impact:** **100-200x capacity increase** with **70% cost reduction**

---

**Last Updated:** December 3, 2025  
**Document Version:** 1.0  
**Author:** Architecture Team  
**Status:** Ready for Implementation
