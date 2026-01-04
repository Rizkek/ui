# 🏗️ Analisis Arsitektur Backend - Reflvy Service

## 📊 **Jenis Arsitektur: Layered Architecture (3-Tier MVC Variant)**

Backend ini menggunakan **Layered Architecture** dengan pola **MVC (Model-View-Controller)** yang diadaptasi untuk REST API, sering disebut sebagai **3-Tier Architecture** atau **Clean Architecture Simplified**.

---

## 🎯 **Identifikasi Arsitektur**

### **Karakteristik yang Terdeteksi:**

✅ **Separation of Concerns** - Pemisahan jelas antara layer  
✅ **Dependency Injection** - Dependencies di-inject via parameter  
✅ **Handler Pattern** - Request handlers terpisah per domain  
✅ **Middleware Pattern** - Authentication middleware  
✅ **Service Layer** - Business logic di layer terpisah  
✅ **Repository Pattern** (Implicit) - Firestore sebagai data layer  

---

## 🏛️ **Struktur Layer (Bottom-Up)**

```
┌─────────────────────────────────────────────────────┐
│                   LAYER 1: DATA                      │
│                 (Database/External)                  │
├─────────────────────────────────────────────────────┤
│  • Firestore Database (Cloud)                       │
│  • Python ML Service (External API)                 │
│  • Firebase Auth Service (External)                 │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│                   LAYER 2: MODELS                    │
│                  (Data Structures)                   │
├─────────────────────────────────────────────────────┤
│  internal/models/                                    │
│    • profile.go        → User data models           │
│    • detectnsfw.go     → NSFW detection models      │
│                                                       │
│  Responsibilities:                                   │
│    - Define data structures                          │
│    - JSON/Firestore serialization                   │
│    - Data validation tags                           │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│                 LAYER 3: SERVICES                    │
│                (Business Logic)                      │
├─────────────────────────────────────────────────────┤
│  internal/services/                                  │
│    • nsfw_classifier.go → NSFW classification logic │
│                                                       │
│  Responsibilities:                                   │
│    - Core business rules                            │
│    - Data transformation                            │
│    - Algorithm implementation                       │
│    - Domain-specific calculations                   │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│                 LAYER 4: HANDLERS                    │
│              (Controllers/Use Cases)                 │
├─────────────────────────────────────────────────────┤
│  internal/handlers/                                  │
│    • detectnsfw/detectnsfw.go → NSFW detection      │
│    • profile/profile.go       → User profile        │
│    • profile/user_details.go  → User details        │
│    • statistic/statistic.go   → Statistics query    │
│    • statistic/dummy.go       → Dev dummy data      │
│                                                       │
│  Responsibilities:                                   │
│    - Handle HTTP requests                           │
│    - Extract request data                           │
│    - Call services for business logic              │
│    - Format HTTP responses                          │
│    - Error handling                                 │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│                LAYER 5: MIDDLEWARE                   │
│              (Cross-cutting Concerns)                │
├─────────────────────────────────────────────────────┤
│  internal/middleware/                                │
│    • auth.go → JWT Firebase authentication          │
│                                                       │
│  Responsibilities:                                   │
│    - Authentication/Authorization                   │
│    - Request validation                             │
│    - Logging (if any)                               │
│    - CORS handling                                  │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│                  LAYER 6: ROUTES                     │
│                  (API Gateway)                       │
├─────────────────────────────────────────────────────┤
│  internal/routes/                                    │
│    • routes.go → Route configuration                │
│                                                       │
│  Responsibilities:                                   │
│    - Route registration                             │
│    - Middleware attachment                          │
│    - HTTP method mapping                            │
│    - Grouping (public/protected)                    │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│                 LAYER 7: ENTRY POINT                 │
│                   (Application)                      │
├─────────────────────────────────────────────────────┤
│  main.go                                             │
│    • Initialize Firebase                            │
│    • Setup Gin router                               │
│    • Register routes                                │
│    • Start HTTP server                              │
└─────────────────────────────────────────────────────┘
```

---

## 📁 **Detailed Layer Breakdown**

### **1. Data Layer (External)**

**Components:**
- Firestore Database (Cloud NoSQL)
- Python ML Service (http://127.0.0.1:5000/detect)
- Firebase Authentication Service

**Purpose:**
- Persistent data storage
- ML model inference
- User authentication

**Dependencies:**
```go
"cloud.google.com/go/firestore"
"firebase.google.com/go/v4/auth"
```

---

### **2. Models Layer**

**Location:** `internal/models/`

**Files:**
- `profile.go` - User profile structures
- `detectnsfw.go` - NSFW detection structures

**Example:**
```go
type ProfileResponse struct {
    Message     string `json:"message"`
    UserID      string `json:"user_id"`
    Email       string `json:"email"`
    DisplayName string `json:"display_name,omitempty"`
    IsVerified  bool   `json:"is_verified"`
    Gender      string `json:"gender,omitempty"`
    Age         int    `json:"age,omitempty"`
}

type StatisticDocument struct {
    UserID      string                    `firestore:"userId"`
    Date        string                    `firestore:"date"`
    GrandTotal  int                       `firestore:"grandTotal"`
    TotalLow    int                       `firestore:"totalLow"`
    TotalMedium int                       `firestore:"totalMedium"`
    TotalHigh   int                       `firestore:"totalHigh"`
    AppCounts   map[string]AppStatCounter `firestore:"appCounts"`
}
```

**Characteristics:**
- ✅ Plain structs (no business logic)
- ✅ JSON/Firestore tags for serialization
- ✅ Clear naming conventions
- ✅ Validation tags (`binding:"required"`)

---

### **3. Services Layer**

**Location:** `internal/services/`

**Files:**
- `nsfw_classifier.go` - NSFW classification algorithm

**Example:**
```go
func ClassifyNSFW(results []models.DetectionResult) int {
    // Business logic: classify NSFW level (0-3)
    // Based on exposed body parts detection scores
    
    exposedCount := 0
    hasHighExposed := false
    
    // ... complex algorithm ...
    
    if hasHighExposed || exposedCount > 2 {
        return 3 // HIGH
    }
    // ... more rules ...
    return 0 // SAFE
}
```

**Characteristics:**
- ✅ Pure functions (no I/O)
- ✅ Stateless
- ✅ Domain-specific logic
- ✅ Easily testable

**Pattern:** **Strategy Pattern** (classification algorithm bisa di-swap)

---

### **4. Handlers Layer (Controllers)**

**Location:** `internal/handlers/`

**Structure:**
```
handlers/
├── detectnsfw/
│   └── detectnsfw.go       → POST /api/detectnsfw
├── profile/
│   ├── profile.go          → GET /api/profile
│   └── user_details.go     → POST /api/profile/details
└── statistic/
    ├── statistic.go        → GET /api/statistics
    └── dummy.go            → POST /api/statistic/dummy
```

**Example Pattern:**
```go
func DetectNSFWHandler(db *firestore.Client) gin.HandlerFunc {
    return func(c *gin.Context) {
        // 1. Extract & validate request
        file, header, err := c.Request.FormFile("image")
        application := c.PostForm("application")
        email := c.Get("email")
        
        // 2. Call external service (Python ML)
        resp := forwardToMLService(file)
        
        // 3. Call business logic (Services)
        nsfwLevel := services.ClassifyNSFW(resp.Results)
        
        // 4. Save to database (if needed)
        if nsfwLevel > 0 {
            updateStatisticDocument(db, email, application, nsfwLevel)
        }
        
        // 5. Return response
        c.JSON(200, gin.H{"nsfw_level": nsfwLevel})
    }
}
```

**Characteristics:**
- ✅ Thin layer (orchestration only)
- ✅ No business logic
- ✅ Dependency injection via closure
- ✅ Clear error handling

**Pattern:** **Handler Pattern** + **Dependency Injection**

---

### **5. Middleware Layer**

**Location:** `internal/middleware/`

**Files:**
- `auth.go` - Firebase JWT authentication

**Example:**
```go
func AuthMiddleware(authClient *auth.Client) gin.HandlerFunc {
    return func(c *gin.Context) {
        // 1. Extract token from header
        authHeader := c.GetHeader("Authorization")
        idToken := strings.TrimPrefix(authHeader, "Bearer ")
        
        // 2. Verify with Firebase
        token, err := authClient.VerifyIDToken(ctx, idToken)
        
        // 3. Set user context
        c.Set("uid", token.UID)
        c.Set("email", token.Claims["email"])
        
        // 4. Continue to handler
        c.Next()
    }
}
```

**Characteristics:**
- ✅ Cross-cutting concerns
- ✅ Chain of responsibility
- ✅ Context propagation

**Pattern:** **Chain of Responsibility Pattern**

---

### **6. Routes Layer (API Gateway)**

**Location:** `internal/routes/`

**Files:**
- `routes.go` - Route configuration

**Example:**
```go
func SetupRoutes(router *gin.Engine, authClient *auth.Client, db *firestore.Client) {
    // Public routes (no auth)
    router.GET("/public", publicHandler)
    router.POST("/api/statistic/dummy", dummyHandler)
    
    // Protected routes (auth required)
    protected := router.Group("/api")
    protected.Use(middleware.AuthMiddleware(authClient))
    {
        protected.GET("/profile", profile.ProfileHandler(authClient, db))
        protected.POST("/profile/details", profile.SaveUserDetailsHandler(db))
        protected.POST("/detectnsfw", detectnsfw.DetectNSFWHandler(db))
        protected.GET("/statistics", statistic.GetStatisticHandler(db))
    }
}
```

**Characteristics:**
- ✅ Centralized routing
- ✅ Middleware composition
- ✅ Route grouping (public/protected)

**Pattern:** **Gateway Pattern** + **Router Pattern**

---

### **7. Entry Point (Application)**

**Location:** `main.go`

**Responsibilities:**
```go
func main() {
    // 1. Initialize dependencies
    authClient, firestoreClient := setupFirebase()
    defer firestoreClient.Close()
    
    // 2. Create router
    router := gin.Default()
    
    // 3. Register routes
    routes.SetupRoutes(router, authClient, firestoreClient)
    
    // 4. Start server
    router.Run("0.0.0.0:3000")
}
```

**Characteristics:**
- ✅ Bootstrap application
- ✅ Dependency wiring
- ✅ Graceful shutdown (defer)

---

## 🔄 **Request Flow Example**

### **Scenario: POST /api/detectnsfw**

```
┌─────────────────────────────────────────────────────┐
│  1. Client Request                                   │
│     POST /api/detectnsfw                            │
│     Authorization: Bearer <token>                   │
│     Body: image=<file>, application=TikTok          │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│  2. Gin Router (routes.go)                          │
│     Match route: POST /api/detectnsfw               │
│     Check middleware chain                          │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│  3. Auth Middleware (middleware/auth.go)            │
│     Extract Bearer token                            │
│     Verify with Firebase Auth                       │
│     Set context: uid, email                         │
│     Call c.Next()                                   │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│  4. Handler (handlers/detectnsfw/detectnsfw.go)     │
│     a. Parse multipart form (image + application)   │
│     b. Get email from context                       │
│     c. Forward image to Python ML service           │
│     d. Receive detection results                    │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│  5. Service (services/nsfw_classifier.go)           │
│     ClassifyNSFW(results []DetectionResult)         │
│     → Analyze exposed body parts                    │
│     → Calculate NSFW level (0-3)                    │
│     → Return int level                              │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│  6. Database Update (Firestore)                     │
│     if nsfwLevel > 0:                               │
│       updateStatisticDocument(db, email, app, level)│
│       → Create/update document in nsfw_stats        │
│       → Increment counters per app & level          │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│  7. Response                                         │
│     {                                                │
│       "nsfw_level": 2,                              │
│       "status": "success"                           │
│     }                                                │
└─────────────────────────────────────────────────────┘
```

---

## 🎯 **Design Patterns Used**

### **1. Layered Architecture**
- Clear separation of concerns
- Each layer has specific responsibility
- Dependencies flow downward

### **2. MVC Variant (for REST API)**
- **Model:** `internal/models/`
- **View:** JSON responses (Gin templates)
- **Controller:** `internal/handlers/`

### **3. Dependency Injection**
```go
// Dependencies injected via function parameters
func DetectNSFWHandler(db *firestore.Client) gin.HandlerFunc {
    // Handler closure has access to db
}

// Called from routes.go:
protected.POST("/detectnsfw", detectnsfw.DetectNSFWHandler(db))
```

### **4. Repository Pattern (Implicit)**
- Firestore acts as repository
- CRUD operations dalam handlers
- Bisa di-extract ke repository layer untuk clean architecture

### **5. Middleware Chain**
```go
protected := router.Group("/api")
protected.Use(middleware.AuthMiddleware(authClient))
```

### **6. Factory Pattern**
```go
// Handler factories return gin.HandlerFunc
func ProfileHandler(authClient, db) gin.HandlerFunc {
    return func(c *gin.Context) { ... }
}
```

### **7. Strategy Pattern**
```go
// Classifier algorithm bisa di-swap
func ClassifyNSFW(results []DetectionResult) int {
    // Different strategies for classification
}
```

---

## ✅ **Kelebihan Arsitektur Ini**

### **1. Maintainability** ⭐⭐⭐⭐⭐
- Clear separation of concerns
- Easy to locate code
- Each layer has single responsibility

### **2. Testability** ⭐⭐⭐⭐
- Services layer pure functions → easy unit test
- Handlers bisa di-mock dengan test DB
- Middleware testable independently

### **3. Scalability** ⭐⭐⭐⭐
- Layer-based scaling possible
- Microservices migration path clear
- Stateless handlers → horizontal scaling

### **4. Modularity** ⭐⭐⭐⭐⭐
- Domain-separated handlers (profile, detectnsfw, statistic)
- Easy to add new features
- Minimal coupling between domains

### **5. Security** ⭐⭐⭐⭐⭐
- Centralized authentication (middleware)
- Token verification before handlers
- Context-based user info propagation

---

## ⚠️ **Kekurangan & Area Improvement**

### **1. Missing Repository Layer**
**Current:**
```go
// Direct Firestore calls in handlers
doc, err := db.Collection("users").Doc(uid).Get(ctx)
```

**Better:**
```go
// Repository abstraction
type UserRepository interface {
    GetByUID(uid string) (*User, error)
    Save(user *User) error
}

// Handler uses repository
user, err := userRepo.GetByUID(uid)
```

**Benefit:** Easier testing, database-agnostic

---

### **2. No Error Handling Abstraction**
**Current:**
```go
if err != nil {
    c.JSON(500, gin.H{"error": "Failed"})
}
```

**Better:**
```go
// Custom error types
type AppError struct {
    Code    int
    Message string
    Err     error
}

// Error handler middleware
func ErrorHandler() gin.HandlerFunc {
    return func(c *gin.Context) {
        c.Next()
        // Handle errors consistently
    }
}
```

---

### **3. No Logging Layer**
**Missing:**
- Structured logging
- Request/response logging
- Error tracking

**Recommendation:**
```go
import "go.uber.org/zap"

logger, _ := zap.NewProduction()
logger.Info("Request received", 
    zap.String("method", "POST"),
    zap.String("path", "/api/detectnsfw"))
```

---

### **4. Business Logic in Handlers**
**Example:** `updateStatisticDocument()` dalam handler

**Better:** Move ke service layer
```go
// services/statistic_service.go
type StatisticService struct {
    db *firestore.Client
}

func (s *StatisticService) UpdateDaily(email, app string, level int) error {
    // Business logic here
}
```

---

### **5. No Input Validation Layer**
**Current:** Validation scattered in handlers

**Better:** Use validator package
```go
import "github.com/go-playground/validator/v10"

type DetectNSFWRequest struct {
    Image       *multipart.FileHeader `form:"image" binding:"required"`
    Application string                `form:"application" binding:"required,min=1"`
}

var validate = validator.New()
if err := validate.Struct(req); err != nil {
    // Handle validation errors
}
```

---

### **6. Configuration Management**
**Current:** Hardcoded values
```go
req, err := http.NewRequest("POST", "http://127.0.0.1:5000/detect", body)
```

**Better:** Use environment variables
```go
import "github.com/spf13/viper"

viper.SetDefault("ml_service_url", "http://127.0.0.1:5000")
mlURL := viper.GetString("ml_service_url")
```

---

## 📊 **Architecture Comparison**

| Aspect | Current (Layered) | Clean Architecture | Microservices |
|--------|-------------------|-------------------|---------------|
| **Complexity** | Low-Medium ⭐⭐⭐ | High ⭐⭐⭐⭐⭐ | Very High ⭐⭐⭐⭐⭐ |
| **Testability** | Good ⭐⭐⭐⭐ | Excellent ⭐⭐⭐⭐⭐ | Excellent ⭐⭐⭐⭐⭐ |
| **Scalability** | Good ⭐⭐⭐⭐ | Good ⭐⭐⭐⭐ | Excellent ⭐⭐⭐⭐⭐ |
| **Learning Curve** | Easy ⭐⭐ | Medium ⭐⭐⭐⭐ | Hard ⭐⭐⭐⭐⭐ |
| **Team Size** | 1-5 devs | 3-10 devs | 10+ devs |
| **Maintenance** | Easy ⭐⭐⭐⭐ | Medium ⭐⭐⭐ | Hard ⭐⭐ |

---

## 🚀 **Recommended Refactoring Path**

### **Phase 1: Add Missing Layers (1-2 weeks)**
1. ✅ Create repository layer
2. ✅ Add validator layer
3. ✅ Implement structured logging
4. ✅ Environment configuration

### **Phase 2: Extract Business Logic (1 week)**
1. ✅ Move handler logic → services
2. ✅ Create domain services per feature
3. ✅ Implement service interfaces

### **Phase 3: Error Handling (1 week)**
1. ✅ Custom error types
2. ✅ Error handling middleware
3. ✅ Consistent error responses

### **Phase 4: Testing (2 weeks)**
1. ✅ Unit tests for services
2. ✅ Integration tests for handlers
3. ✅ E2E tests for critical flows

### **Phase 5: Documentation (1 week)**
1. ✅ OpenAPI/Swagger specs
2. ✅ Architecture diagrams
3. ✅ Developer guides

---

## 📚 **Conclusion**

### **Architecture Type:**
**3-Tier Layered Architecture** (MVC Variant for REST API)

### **Overall Rating:** ⭐⭐⭐⭐ (4/5)

**Strengths:**
- ✅ Clear separation of concerns
- ✅ Easy to understand and navigate
- ✅ Good for small-medium projects
- ✅ Framework conventions (Gin) followed well
- ✅ Dependency injection via closures

**Weaknesses:**
- ⚠️ Missing repository layer
- ⚠️ Some business logic in handlers
- ⚠️ No structured logging
- ⚠️ Hardcoded configurations
- ⚠️ No input validation layer

**Recommendation:**
Arsitektur ini **SANGAT BAIK** untuk:
- ✅ MVP/Prototype projects
- ✅ Small teams (1-5 developers)
- ✅ Projects with clear domain boundaries
- ✅ REST API services

Pertimbangkan upgrade ke **Clean Architecture** jika:
- Project scale meningkat (10+ endpoints)
- Team bertambah (5+ developers)
- Butuh multiple storage backends
- Testing coverage target >80%

---

**Analyzed By:** GitHub Copilot  
**Date:** December 3, 2025  
**Framework:** Gin (Go)  
**Database:** Firestore  
**Architecture:** Layered (3-Tier MVC Variant)
