#ifndef PRIMITIVECOLLECT_INCLUDED
#define PRIMITIVECOLLECT_INCLUDED

#include "Interfaces/ICollect.mqh"

template<typename T>
class CPrimitiveCollect : public ICollect<T>
{
  private:
    // Data
    T _value[];

  private:
    // Properties
    int _reserve;

  private:
    // Variables
    int _selectIndex;
    int _lastIndex;
    bool _wasModified;
    int _count;

  public:
    CPrimitiveCollect(int reserve = 0);
    ~CPrimitiveCollect();

  public:
    bool InRange(int index) { return (index >= 0 && index < Count()); };

  public:
    //- GET
    virtual int Count();
    virtual int Contains(T value);
    virtual T Get(int index);
    virtual bool Get(int index, T& value);
    virtual bool Copy(T& values[]);

    //- SET
    virtual bool Insert(T value);
    virtual bool Set(int index, T value);
    virtual bool Replace(int index, T value);
    virtual bool Remove(int index);
    virtual bool Resize(uint size);
    virtual void Clear();

  public:
    int GetSelectIndex() { return (_selectIndex); };
    int GetLastIndex() { return (_lastIndex); };

  public:
    // Defines
    //- GET
    bool WasModified() { return (_wasModified); };
    bool WasModified(bool newValue);
    int GetReserve() { return (_reserve); };

    //- SET
    void SetReserve(int value);
    void SetModified(bool value);

  protected:
    void RamFree();
};

/**
 * Construtores e Destrutores
 */
template<typename T>
CPrimitiveCollect::CPrimitiveCollect(int reserve = 0)
    : _count(0),
      _reserve(reserve),
      _wasModified(false),
      _selectIndex(-1),
      _lastIndex(-1)
{
}
template<typename T>
CPrimitiveCollect::~CPrimitiveCollect()
{
}

/**
 * Definições
 */
template<typename T>
void CPrimitiveCollect::SetReserve(int value)
{
  _reserve = value;
}

template<typename T>
void CPrimitiveCollect::SetModified(bool value)
{
  _wasModified = value;
}

template<typename T>
bool CPrimitiveCollect::WasModified(bool newValue)
{
  bool v = _wasModified;
  SetModified(newValue);
  return (v);
}

/**
 * Retornos
 */
template<typename T>
int CPrimitiveCollect::Count()
{
  return (_count);
}

template<typename T>
int CPrimitiveCollect::Contains(T value)
{
  int size = Count();
  if(size > 0)
    {
      T ref = NULL;
      for(int i = 0; i < size; i++)
        {
          if(Get(i, ref))
            {
              if(ref == value)
                {
                  return (i);
                }
            }
        }
    }
  return (-1);
}

template<typename T>
T CPrimitiveCollect::Get(int index)
{
  if(InRange(index))
    {
      _selectIndex = index;
      return (_value[index]);
    }
  return (NULL);
}

template<typename T>
bool CPrimitiveCollect::Get(int index, T& value)
{
  if(InRange(index))
    {
      _selectIndex = index;
      value = _value[index];
      return (true);
    }
  return (false);
}

template<typename T>
bool CPrimitiveCollect::Copy(T& values[])
{
  int size = Count();
  if(size > 0)
    {
      ArrayCopy(values, _value);
      return (true);
    }
  return (false);
}

/**
 * Inserção
 */
template<typename T>
bool CPrimitiveCollect::Insert(T value)
{
  int lastSize = _count;
  _selectIndex = lastSize;
  _lastIndex = _selectIndex;
  if(Resize(_count + 1))
    {
      _value[lastSize] = value;
      SetModified(true);
      return (true);
    }
  return (false);
}

template<typename T>
bool CPrimitiveCollect::Set(int index, T value)
{
  if(!Replace(index, value))
    {
      return (Insert(value));
    }
  return (true);
}

template<typename T>
bool CPrimitiveCollect::Replace(int index, T value)
{
  if(InRange(index))
    {
      _selectIndex = index;
      _lastIndex = _selectIndex;
      _value[index] = value;
      SetModified(true);
      return (true);
    }
  return (false);
}

template<typename T>
bool CPrimitiveCollect::Remove(int index)
{
  if(InRange(index))
    {
      ArrayRemove(_value, index, 1);
      _count--;
      SetModified(true);
      return (true);
    }
  return (false);
}

template<typename T>
bool CPrimitiveCollect::Resize(uint size)
{
  if(ArrayResize(_value, size, _reserve) >= 0)
    {
      _count = (int)_value.Size();
      SetModified(true);
      return (true);
    }
  return (true);
}

template<typename T>
void CPrimitiveCollect::Clear()
{
  int size = Count();
  if(size > 0)
    {
      for(int i = size - 1; i >= 0; i--)
        {
          Remove(i);
        }
    }
  RamFree();
}

/**
 * Limpa o uso da memória
 */
template<typename T>
void CPrimitiveCollect::RamFree()
{
  ArrayFree(_value);
  SetModified(true);
}

#endif /* PRIMITIVECOLLECT_INCLUDED */
