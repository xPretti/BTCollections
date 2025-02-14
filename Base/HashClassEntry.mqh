#ifndef B2994F36_1204_46BD_BCEB_2FDDFCDB8583_INCLUDED
#define B2994F36_1204_46BD_BCEB_2FDDFCDB8583_INCLUDED

#include "HashEntry.mqh"

template<typename T, typename V>
class CHashClassEntry : public CHashEntry<T, V*>
{
  private:
    bool _deletePointerOnUnload;

  public:
    CHashClassEntry(bool deletePointerOnUnload = true)
        : _deletePointerOnUnload(deletePointerOnUnload){};

    CHashClassEntry(T keyRef, V* valueRef, bool deletePointerOnUnload = true)
        : CHashEntry<T, V*>(keyRef, valueRef),
          _deletePointerOnUnload(deletePointerOnUnload){};

    ~CHashClassEntry()
    {
      if(_deletePointerOnUnload)
        {
          delete _value;
        }
    };

  public:
    virtual T GetKey() { return (_key); };
    virtual V* GetValue() { return (_value); };
    virtual void SetKey(T keyRef) { _key = keyRef; };
    virtual void SetValue(V* valueRef)
    {
      if(!CPointerUtils::IsEqual(_value, valueRef))
        CPointerUtils::Delete(_value);
      _value = valueRef;
    };
};

#endif /* B2994F36_1204_46BD_BCEB_2FDDFCDB8583_INCLUDED */
