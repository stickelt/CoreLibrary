namespace CoreLibrary.DataAccess;

public interface IBaseRepository<T> where T : class
{
    Task<T?> GetByIdAsync(int id);
    Task<IEnumerable<T>> GetAllAsync();
}
