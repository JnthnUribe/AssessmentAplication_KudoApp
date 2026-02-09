using MongoDB.Bson;
using MongoDB.Driver;

var builder = WebApplication.CreateBuilder(args);

// --- 1. CONFIGURACIÓN MONGODB (Sin inyección compleja) ---
var mongoClient = new MongoClient("mongodb://localhost:27017");
var database = mongoClient.GetDatabase("KudoDB");

// Registramos la base de datos para poder pedirla en los controladores
builder.Services.AddSingleton(database);

// --- 2. SERVICIOS ---
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// --- 3. CORS (Vital para que Flutter Web funcione) ---
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

// --- 4. PIPELINE HTTP ---
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors("AllowAll");
app.UseAuthorization();
app.MapControllers();

app.Run();