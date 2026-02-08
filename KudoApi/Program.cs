using KudoApi.Services;

var builder = WebApplication.CreateBuilder(args);

// ====== SERVICIOS ======

// MongoDB - Registrar como Singleton
builder.Services.AddSingleton<MongoDbService>();

// Controllers
builder.Services.AddControllers();

// Swagger para documentación
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// CORS - Permitir cualquier origen (para desarrollo)
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

// ====== MIDDLEWARE ======

// Swagger solo en desarrollo
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Habilitar CORS antes de los endpoints
app.UseCors("AllowAll");

// Mapear controllers
app.MapControllers();

// Mensaje de inicio
Console.WriteLine("🚀 KUDO API iniciada en http://localhost:5000");
Console.WriteLine("📚 Swagger disponible en http://localhost:5000/swagger");

app.Run();
