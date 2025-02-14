#ifndef CA163B87_3A2B_4B6D_AEFC_BDE5ABE161A9_INCLUDED
#define CA163B87_3A2B_4B6D_AEFC_BDE5ABE161A9_INCLUDED

#include "Interfaces/IHashStructCollect.mqh"

#include "ClassCollect.mqh"
#include <Generic/HashMap.mqh>

#include "Base/HashStructEntry.mqh"
#include "PrimitiveCollect.mqh"

template<typename T, typename V>
class CHashStructCollect : public IHashStructCollect<T, V>
{
  private:
    // Datas
    CHashMap<T, int> hashData;
    CClassCollect<CHashStructEntry<T, V>> classData;

    // Cache
    CPrimitiveCollect<int> _cacheIndex;

    // Empty
    V _empty;

  public:
    CHashStructCollect(int reserve = 0, int cacheLimit = 30);
    ~CHashStructCollect();

    //- GET
    virtual int Count();
    virtual bool Contains(T key);
    virtual CHashStructEntry<T, V>* Get(T key);
    virtual bool Get(T key, CHashStructEntry<T, V>*& value);
    virtual bool Get(T key, V& value);
    CClassCollect<CHashStructEntry<T, V>>* GetData() { return (&classData); };

    //- SET
    virtual bool Insert(T key, V& value);
    virtual bool Set(T key, V& value);
    virtual bool Replace(T key, V& value);
    virtual bool Remove(T key);
    virtual void Clear();

  public:
    virtual CHashStructEntry<T, V>* GetByIndex(int index) { return (classData.Get(index)); };
    virtual bool GetByIndex(int index, CHashStructEntry<T, V>*& value) { return (classData.Get(index, value)); };
    virtual bool GetByIndex(int index, V& value);

  public:
    int GetKeyIndex(T key) override;

  private:
    void UpdateIndexes ();
    void ReorderIndexes(int start);
    bool InsertByCache(T key, V& value);
};

/**
 * Construtores e Destrutores
 */
template<typename T, typename V>
CHashStructCollect::CHashStructCollect(int reserve = 0, int cacheLimit = 30)
    : hashData(),
      classData(reserve, true),
      _cacheIndex(cacheLimit)
{
}
template<typename T, typename V>
CHashStructCollect::~CHashStructCollect()
{
}

/**
 * Métodos de atualização dos indexes
 */
template<typename T, typename V>
void CHashStructCollect::UpdateIndexes()
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
void CHashStructCollect::ReorderIndexes(int start)
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
  CHashStructEntry<T, V>* hashValue;
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
bool CHashStructCollect::GetByIndex(int index, V& value)
{
  CHashStructEntry<T, V>* hashValue = classData.Get(index);
  if(CPointerUtils::IsValid(hashValue))
    {
      value = hashValue.GetValue();
      return (true);
    }
  return (false);
}

/**
 * Métodos de retornos
 */
template<typename T, typename V>
int CHashStructCollect::Count()
{
  return (classData.Count());
}

template<typename T, typename V>
bool CHashStructCollect::Contains(T key)
{
  return (hashData.ContainsKey(key));
}

template<typename T, typename V>
CHashStructEntry<T, V>* CHashStructCollect::Get(T key)
{
  int index = GetKeyIndex(key);
  if(index >= 0)
    {
      return (classData.Get(index));
    }
  return (NULL);
}

template<typename T, typename V>
bool CHashStructCollect::Get(T key, CHashStructEntry<T, V>*& value)
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
bool CHashStructCollect::Get(T key, V& value)
{
  CHashStructEntry<T, V>* result;
  if(Get(key, result))
    {
      value = result.GetValue();
      return (true);
    }
  return (false);
}

template<typename T, typename V>
int CHashStructCollect::GetKeyIndex(T key)
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
bool CHashStructCollect::Insert(T key, V& value)
{
  if(Contains(key))
    {
      return (false);
    }
  if(InsertByCache(key, value))
    {
      return (true);
    }
  CHashStructEntry<T, V>* hashValue = new CHashStructEntry<T, V>(key, value);
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
bool CHashStructCollect::InsertByCache(T key, V& value)
{
  int cached = _cacheIndex.Count();
  if(cached > 0)
    {
      int index = _cacheIndex.Get(cached - 1);
      _cacheIndex.Remove(cached - 1);
      CHashStructEntry<T, V>* hashValue = GetByIndex(index);
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
bool CHashStructCollect::Set(T key, V& value)
{
  int index = GetKeyIndex(key);
  if(index >= 0)
    {
      CHashStructEntry<T, V>* hashValue = GetByIndex(index);
      hashValue.SetValue(value);
      return (true);
    }
  return (Insert(key, value));
}

template<typename T, typename V>
bool CHashStructCollect::Replace(T key, V& value)
{
  int index = GetKeyIndex(key);
  if(index >= 0)
    {
      CHashStructEntry<T, V>* hashValue = GetByIndex(index);
      hashValue.SetValue(value);
      return (true);
    }
  return (false);
}

template<typename T, typename V>
bool CHashStructCollect::Remove(T key)
{
  int index = GetKeyIndex(key);
  if(index >= 0)
    {
      CHashStructEntry<T, V>* hashValue = GetByIndex(index);
      hashValue.SetValue(_empty);
      _cacheIndex.Insert(index);
      hashData.Remove(key);
      UpdateIndexes ();
      return (true);
    }
  return (false);
}

template<typename T, typename V>
void CHashStructCollect::Clear()
{
  classData.Clear();
  hashData.Clear();
  _cacheIndex.Clear();
}

#endif /* CA163B87_3A2B_4B6D_AEFC_BDE5ABE161A9_INCLUDED */
