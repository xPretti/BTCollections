#ifndef FB1F256E_B9B6_4F5E_A0C1_4A304F9A50BE_INCLUDED
#define FB1F256E_B9B6_4F5E_A0C1_4A304F9A50BE_INCLUDED

template<typename T, typename V>
class CHashEntry
{
  protected:
    T _key;
    V _value;

  public:
    CHashEntry(){};
    CHashEntry(T keyRef, V valueRef)
        : _key(keyRef),
          _value(valueRef){};

    ~CHashEntry(){};

  public:
    virtual T GetKey() { return (_key); };
    virtual V GetValue() { return (_value); };
    virtual void SetKey(T keyRef) { _key = keyRef; };
    virtual void SetValue(V valueRef) { _value = valueRef; };
};

#endif /* FB1F256E_B9B6_4F5E_A0C1_4A304F9A50BE_INCLUDED */
