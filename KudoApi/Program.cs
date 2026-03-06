using KudoApi.Core.Application.Services;
using KudoApi.Core.Domain.Entities;
using KudoApi.Core.Domain.Interfaces;
using KudoApi.Infrastructure.Data;
using KudoApi.Infrastructure.Repositories;
using DotNetEnv;
using MongoDB.Driver;

// Load .env file variables into environment variables
Env.Load();

var builder = WebApplication.CreateBuilder(args);

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

// Register IMongoDatabase for controllers that inject it directly
builder.Services.AddSingleton<IMongoDatabase>(sp =>
{
    var config = sp.GetRequiredService<IConfiguration>();
    var connStr = config.GetValue<string>("MongoDbSettings:ConnectionString") ?? connectionString;
    var dbName = config.GetValue<string>("MongoDbSettings:DatabaseName") ?? databaseName;
    var client = new MongoClient(connStr);
    return client.GetDatabase(dbName);
});

// Repositories
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<IProjectRepository, ProjectRepository>();
builder.Services.AddScoped<IReviewRepository, ReviewRepository>();
builder.Services.AddScoped<IVoteRepository, VoteRepository>();
builder.Services.AddScoped<ICommentRepository, CommentRepository>();

// Services
builder.Services.AddHttpClient();
builder.Services.AddScoped<CloudinaryService>();
builder.Services.AddScoped<UserService>();
builder.Services.AddScoped<ProjectService>();
builder.Services.AddScoped<ReviewService>();
builder.Services.AddScoped<VoteService>();
builder.Services.AddScoped<CommentService>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Only redirect to HTTPS in development; Render handles SSL at proxy level
if (app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}

app.UseCors("AllowAll");

app.UseAuthorization();

app.MapControllers();

var port = Environment.GetEnvironmentVariable("PORT") ?? "5145";
app.Urls.Add($"http://0.0.0.0:{port}");
app.Run();