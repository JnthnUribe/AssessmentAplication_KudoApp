using KudoApi.Core.Application.Services;
using KudoApi.Core.Domain.Entities;
using KudoApi.Core.Domain.Interfaces;
using KudoApi.Infrastructure.Data;
using KudoApi.Infrastructure.Repositories;
using DotNetEnv;

// Load .env file variables into environment variables
Env.Load();

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Add services to the container.

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

app.Run();