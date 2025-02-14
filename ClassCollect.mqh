#ifndef C704912D_CAF1_47ED_B18D_CA6890874DAF_INCLUDED
#define C704912D_CAF1_47ED_B18D_CA6890874DAF_INCLUDED

#include "PrimitiveCollect.mqh"

#include "Interfaces/IClassCollect.mqh"

#include <UCUtils/PointerUtils.mqh>

template<typename T>
class CClassCollect : public IClassCollect<T*>
{
  private:
    // Data
    CPrimitiveCollect<T*> data;

    // Properties
    bool _deletePointerOnUnload;

  public:
    CClassCollect(int reserve = 0, bool deletePointerOnUnload = true);
    ~CClassCollect();

  public:
    bool InRange(int index) { return (data.InRange(index)); };

  public:
    //- GET
    virtual int Count() { return (data.Count()); };
    virtual int Contains(T* value);
    virtual T* Get(int index) { return (data.Get(index)); };
    virtual bool Get(int index, T*& value);
    virtual bool Copy(T*& values[]) { return (data.Copy(values)); };

    //- SET
    virtual bool Insert(T* value);
    virtual bool Set(int index, T* value);
    virtual bool Replace(int index, T* value);
    virtual bool Remove(int index);
    virtual bool RemovePointer(int index);
    virtual bool RemovePointerByNotEqual(int index, T* compareValue);
    virtual bool RemoveNoDelete(int index) { return (data.Remove(index)); };
    virtual bool Resize(uint size);
    virtual bool ResizeNoRemove(uint size) { return (data.Resize(size)); };
    virtual void Clear();
    virtual void ClearNoDelete() { data.Clear(); };

  public:
    int GetSelectIndex() { return (data.GetSelectIndex()); };
    int GetLastIndex() { return (data.GetLastIndex()); };

  public:
    // Defines
    //- GET
    bool WasModified() { return (data.WasModified()); };
    bool WasModified(bool newValue) { return (data.WasModified(newValue)); };

    //- SET
    void SetReserve(int value) { data.SetReserve(value); };
    void SetModified(bool value) { data.SetModified(value); };
};

/**
 * Construtores e Destrutores
 */
template<typename T>
CClassCollect::CClassCollect(int reserve = 0, bool deletePointerOnUnload = true)
    : data(reserve),
      _deletePointerOnUnload(deletePointerOnUnload)
{
}
template<typename T>
CClassCollect::~CClassCollect()
{
  if(_deletePointerOnUnload)
    {
      Clear();
    }
  else
    {
      ClearNoDelete();
    }
}

/**
 * Retornos
 */
template<typename T>
int CClassCollect::Contains(T* value)
{
  int size = Count();
  if(size > 0 && CPointerUtils::IsValid(value))
    {
      T* ref = NULL;
      for(int i = 0; i < size; i++)
        {
          if(Get(i, ref))
            {
              if(CPointerUtils::IsEqual(ref, value))
                {
                  return (i);
                }
            }
        }
    }
  return (-1);
}

template<typename T>
bool CClassCollect::Get(int index, T*& value)
{
  value = Get(index);
  return (CPointerUtils::IsValid(value));
}

/**
 * Inserção
 */
template<typename T>
bool CClassCollect::Insert(T* value)
{
  if(CPointerUtils::IsValid(value))
    {
      return (data.Insert(value));
    }
  return (false);
}

template<typename T>
bool CClassCollect::Set(int index, T* value)
{
  if(CPointerUtils::IsValid(value))
    {
      if(RemovePointerByNotEqual(index, value))
        {
          return (data.Set(index, value));
        }
    }
  return (false);
}

template<typename T>
bool CClassCollect::Replace(int index, T* value)
{
  if(CPointerUtils::IsValid(value))
    {
      if(RemovePointerByNotEqual(index, value))
        {
          return (data.Replace(index, value));
        }
    }
  return (false);
}

template<typename T>
bool CClassCollect::Remove(int index)
{
  RemovePointer(index);
  return (data.Remove(index));
}

template<typename T>
bool CClassCollect::RemovePointer(int index)
{
  T* getRef = NULL;
  if(Get(index, getRef))
    {
      CPointerUtils::Delete(getRef);
      return (true);
    }
  return (false);
}

template<typename T>
bool CClassCollect::RemovePointerByNotEqual(int index, T* compareValue)
{
  T* getRef = NULL;
  if(Get(index, getRef))
    {
      if(!CPointerUtils::IsEqual(getRef, compareValue))
        {
          CPointerUtils::Delete(getRef);
          return (true);
        }
    }
  return (false);
}

template<typename T>
bool CClassCollect::Resize(uint size)
{
  int count = Count();
  int removeElements = count - (int)size;
  if(removeElements > 0)
    {
      for(int i = count - 1; i >= (int)size; i--)
        {
          Remove(i);
        }
    }
  return (data.Resize(size));
}

template<typename T>
void CClassCollect::Clear()
{
  int size = Count();
  if(size > 0)
    {
      for(int i = size - 1; i >= 0; i--)
        {
          Remove(i);
        }
      data.Clear();
    }
}

#endif /* C704912D_CAF1_47ED_B18D_CA6890874DAF_INCLUDED */
