#ifndef CC5A2530_A31C_40C2_9BC6_381E24400621_INCLUDED
#define CC5A2530_A31C_40C2_9BC6_381E24400621_INCLUDED

#include "Interfaces/IStructCollect.mqh"

template<typename T>
class CStructCollect : public IStructCollect<T>
{
  private:
    // Data
    T _value[];

    // Properties
    int _reserve;

    // Empty
    T _empty;

  private:
    // Variables
    int _selectIndex;
    int _lastIndex;
    bool _wasModified;
    int _count;

  public:
    CStructCollect(int reserve = 0);
    CStructCollect(int reserve, T& emptyValue);
    ~CStructCollect();

  public:
    bool InRange(int index) { return (index >= 0 && index < Count()); };

  public:
    //- GET
    virtual int Count();
    virtual T Get(int index);
    virtual bool Get(int index, T& value);

    //- SET
    virtual bool Insert(T& value);
    virtual bool Set(int index, T& value);
    virtual bool Replace(int index, T& value);
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
CStructCollect::CStructCollect(int reserve = 0)
    : _count(0),
      _reserve(reserve),
      _wasModified(false),
      _selectIndex(-1),
      _lastIndex(-1)
{
}
template<typename T>
CStructCollect::CStructCollect(int reserve, T& emptyValue)
    : _count(0),
      _reserve(reserve),
      _wasModified(false),
      _selectIndex(-1),
      _lastIndex(-1)
{
  _empty = emptyValue;
}
template<typename T>
CStructCollect::~CStructCollect()
{
}

/**
 * Definições
 */
template<typename T>
void CStructCollect::SetReserve(int value)
{
  _reserve = value;
}

template<typename T>
void CStructCollect::SetModified(bool value)
{
  _wasModified = value;
}

template<typename T>
bool CStructCollect::WasModified(bool newValue)
{
  bool v = _wasModified;
  SetModified(newValue);
  return (v);
}

/**
 * Retornos
 */
template<typename T>
int CStructCollect::Count()
{
  return (_count);
}

template<typename T>
T CStructCollect::Get(int index)
{
  if(InRange(index))
    {
      _selectIndex = index;
      return (_value[index]);
    }
  return (_empty);
}

template<typename T>
bool CStructCollect::Get(int index, T& value)
{
  if(InRange(index))
    {
      _selectIndex = index;
      value = _value[index];
      return (true);
    }
  return (false);
}

/**
 * Inserção
 */
template<typename T>
bool CStructCollect::Insert(T& value)
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
bool CStructCollect::Set(int index, T& value)
{
  if(!Replace(index, value))
    {
      return (Insert(value));
    }
  return (true);
}

template<typename T>
bool CStructCollect::Replace(int index, T& value)
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
bool CStructCollect::Remove(int index)
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
bool CStructCollect::Resize(uint size)
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
void CStructCollect::Clear()
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
void CStructCollect::RamFree()
{
  ArrayFree(_value);
  SetModified(true);
}

#endif /* CC5A2530_A31C_40C2_9BC6_381E24400621_INCLUDED */
