namespace KudoApi.Models;

public class VoteRequest
{
    public string UserId { get; set; } = string.Empty;
    public int Score { get; set; }
    public string? Comment { get; set; }
}
