using KudoApi.Core.Application.Services;
using KudoApi.Core.Domain.Entities;
using KudoApi.Core.Domain.Interfaces;
using KudoApi.Infrastructure.Data;
using KudoApi.Infrastructure.Repositories;
using DotNetEnv;

// Load .env file variables into environment variables
Env.Load();

var builder = WebApplication.CreateBuilder(args);

<<<<<<< Updated upstream
// Add services to the container.
// Add services to the container.
=======
// --- 0. CARGAR .env (para desarrollo local) ---
var envPath = Path.Combine(Directory.GetCurrentDirectory(), ".env");
if (File.Exists(envPath))
{
    foreach (var line in File.ReadAllLines(envPath))
    {
        if (string.IsNullOrWhiteSpace(line) || line.StartsWith("#")) continue;
        var parts = line.Split('=', 2);
        if (parts.Length == 2)
            Environment.SetEnvironmentVariable(parts[0].Trim(), parts[1].Trim());
    }
}

// --- 1. CONFIGURACIÓN MONGODB ---
var connectionString = Environment.GetEnvironmentVariable("MongoDbSettings__ConnectionString")
    ?? "mongodb://localhost:27017";
var databaseName = Environment.GetEnvironmentVariable("MongoDbSettings__DatabaseName")
    ?? "KudoDB";

Console.WriteLine($"🔗 Conectando a MongoDB: {(connectionString.Contains("mongodb+srv") ? "Atlas (nube)" : "Local")}");
Console.WriteLine($"📦 Base de datos: {databaseName}");

var mongoClient = new MongoClient(connectionString);
var database = mongoClient.GetDatabase(databaseName);
>>>>>>> Stashed changes

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// MongoDB Configuration
builder.Services.AddSingleton<MongoDbContext>();

// Repositories
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<IProjectRepository, ProjectRepository>();
builder.Services.AddScoped<IReviewRepository, ReviewRepository>();

// Services
builder.Services.AddScoped<UserService>();
builder.Services.AddScoped<ProjectService>();
builder.Services.AddScoped<ReviewService>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseCors("AllowAll");

app.UseAuthorization();

app.MapControllers();

var port = Environment.GetEnvironmentVariable("PORT") ?? "5145";
app.Urls.Add($"http://0.0.0.0:{port}");
app.Run();