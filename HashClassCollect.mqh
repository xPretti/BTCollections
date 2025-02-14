#ifndef BE864765_920C_4AF3_8788_4591551E4275_INCLUDED
#define BE864765_920C_4AF3_8788_4591551E4275_INCLUDED

#include "Interfaces/IHashClassCollect.mqh"

#include "ClassCollect.mqh"
#include <Generic/HashMap.mqh>

#include "Base/HashClassEntry.mqh"
#include "PrimitiveCollect.mqh"

template<typename T, typename V>
class CHashClassCollect : public IHashClassCollect<T, V>
{
  private:
    // Datas
    CHashMap<T, int> hashData;
    CClassCollect<CHashClassEntry<T, V>> classData;

    // Cache
    CPrimitiveCollect<int> _cacheIndex;

  public:
    CHashClassCollect(int reserve = 0, bool deletePointerOnUnload = true, int cacheLimit = 30);
    ~CHashClassCollect();

    //- GET
    virtual int Count();
    virtual bool Contains(T key);
    virtual CHashClassEntry<T, V>* Get(T key);
    virtual bool Get(T key, CHashClassEntry<T, V>*& value);
    virtual bool Get(T key, V*& value);

    //- SET
    virtual bool Insert(T key, V* value);
    virtual bool Set(T key, V* value);
    virtual bool Replace(T key, V* value);
    virtual bool Remove(T key);
    virtual void Clear();
    virtual void ClearNoDelete();

  public:
    virtual CHashClassEntry<T, V>* GetByIndex(int index) { return (classData.Get(index)); };
    virtual bool GetByIndex(int index, CHashClassEntry<T, V>*& value) { return (classData.Get(index, value)); };
    virtual bool GetByIndex(int index, V*& value);

  public:
    int GetKeyIndex(T key) override;

  private:
    void UpdadeIndexes();
    void ReorderIndexes(int start);
    bool InsertByCache(T key, V* value);
};

/**
 * Construtores e Destrutores
 */
template<typename T, typename V>
CHashClassCollect::CHashClassCollect(int reserve = 0, bool deletePointerOnUnload = true, int cacheLimit = 30)
    : hashData(),
      classData(reserve, deletePointerOnUnload),
      _cacheIndex(cacheLimit)
{
}
template<typename T, typename V>
CHashClassCollect::~CHashClassCollect()
{
}

/**
 * Métodos de atualização dos indexes
 */
template<typename T, typename V>
void CHashClassCollect::UpdadeIndexes()
{
  int cached = _cacheIndex.Count();
  if(cached > _cacheIndex.GetReserve())
    {
      int sortingArray[];
      _cacheIndex.Copy(sortingArray);
      ArrayResize(sortingArray, cached);
      ArraySort(sortingArray);
      int startIndex = -1;
      for(int i = cached - 1; i >= 0; i--)
        {
          int index = sortingArray[i];
          if(startIndex == -1 || index <= startIndex)
            {
              startIndex = index;
            }
          classData.Remove(index);
          _cacheIndex.Remove(i);
        }
      ReorderIndexes(startIndex);
    }
}
/**
 * Método de atualização de hash
 */
template<typename T, typename V>
void CHashClassCollect::ReorderIndexes(int start)
{
  if(start <= -1)
    {
      return;
    }
  int size = classData.Count();
  if(size <= 0 || start >= size)
    {
      return;
    }
  CHashClassEntry<T, V>* hashValue;
  for(int i = start; i < size; i++)
    {
      if(classData.Get(i, hashValue))
        {
          hashData.TrySetValue(hashValue.GetKey(), i);
        }
    }
}

/**
 * Retornos diretos
 */
template<typename T, typename V>
bool CHashClassCollect::GetByIndex(int index, V*& value)
{
  CHashClassEntry<T, V>* hashValue = classData.Get(index);
  if(CPointerUtils::IsValid(hashValue))
    {
      value = hashValue.GetValue();
      return (CPointerUtils::IsValid(value));
    }
  return (false);
}

/**
 * Métodos de retornos
 */
template<typename T, typename V>
int CHashClassCollect::Count()
{
  return (classData.Count());
}

template<typename T, typename V>
bool CHashClassCollect::Contains(T key)
{
  return (hashData.ContainsKey(key));
}

template<typename T, typename V>
CHashClassEntry<T, V>* CHashClassCollect::Get(T key)
{
  int index = GetKeyIndex(key);
  if(index >= 0)
    {
      return (classData.Get(index));
    }
  return (NULL);
}

template<typename T, typename V>
bool CHashClassCollect::Get(T key, CHashClassEntry<T, V>*& value)
{
  int index = GetKeyIndex(key);
  if(index >= 0)
    {
      value = classData.Get(index);
      return (true);
    }
  return (false);
}

template<typename T, typename V>
bool CHashClassCollect::Get(T key, V*& value)
{
  CHashClassEntry<T, V>* result;
  if(Get(key, result))
    {
      value = result.GetValue();
      return (CPointerUtils::IsValid(value));
    }
  return (false);
}

template<typename T, typename V>
int CHashClassCollect::GetKeyIndex(T key)
{
  int index = -1;
  if(hashData.TryGetValue(key, index))
    {
      return (index);
    }
  return (-1);
}

/**
 * Métodos de inserção
 */
template<typename T, typename V>
bool CHashClassCollect::Insert(T key, V* value)
{
  if(Contains(key))
    {
      return (false);
    }
  if(InsertByCache(key, value))
    {
      return (true);
    }
  CHashClassEntry<T, V>* hashValue = new CHashClassEntry<T, V>(key, value);
  if(classData.Insert(hashValue))
    {
      int index = classData.GetLastIndex();
      hashData.Add(key, index);
      return (true);
    }
  delete(hashValue);
  return (false);
}

template<typename T, typename V>
bool CHashClassCollect::InsertByCache(T key, V* value)
{
  int cached = _cacheIndex.Count();
  if(cached > 0)
    {
      int index = _cacheIndex.Get(cached - 1);
      _cacheIndex.Remove(cached - 1);
      CHashClassEntry<T, V>* hashValue = GetByIndex(index);
      if(CPointerUtils::IsValid(hashValue))
        {
          hashValue.SetKey(key);
          hashValue.SetValue(value);
          hashData.Add(key, index);
          return (true);
        }
      else
        {
          classData.Remove(index);
          ReorderIndexes(index);
        }
    }
  return (false);
}

template<typename T, typename V>
bool CHashClassCollect::Set(T key, V* value)
{
  int index = GetKeyIndex(key);
  if(index >= 0)
    {
      CHashClassEntry<T, V>* hashValue = GetByIndex(index);
      hashValue.SetValue(value);
      return (true);
    }
  return (Insert(key, value));
}

template<typename T, typename V>
bool CHashClassCollect::Replace(T key, V* value)
{
  int index = GetKeyIndex(key);
  if(index >= 0)
    {
      CHashClassEntry<T, V>* hashValue = GetByIndex(index);
      hashValue.SetValue(value);
      return (true);
    }
  return (false);
}

template<typename T, typename V>
bool CHashClassCollect::Remove(T key)
{
  int index = GetKeyIndex(key);
  if(index >= 0)
    {
      CHashClassEntry<T, V>* hashValue = GetByIndex(index);
      hashValue.SetValue(NULL);
      _cacheIndex.Insert(index);
      hashData.Remove(key);
      UpdadeIndexes();
      return (true);
    }
  return (false);
}

template<typename T, typename V>
void CHashClassCollect::Clear()
{
  classData.Clear();
  hashData.Clear();
  _cacheIndex.Clear();
}

template<typename T, typename V>
void CHashClassCollect::ClearNoDelete()
{
  classData.ClearNoDelete();
  hashData.Clear();
  _cacheIndex.Clear();
}

#endif /* BE864765_920C_4AF3_8788_4591551E4275_INCLUDED */
