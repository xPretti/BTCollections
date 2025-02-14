#ifndef F189C0E2_B14E_4223_9FE1_50F57012A521_INCLUDED
#define F189C0E2_B14E_4223_9FE1_50F57012A521_INCLUDED

template<typename T, typename V>
class CHashStructEntry
{
  protected:
    T _key;
    V _value;

  public:
    CHashStructEntry(){};
    CHashStructEntry(T keyRef, V& valueRef)
        : _key(keyRef)
    {
      _value = valueRef;
    };

    ~CHashStructEntry(){};

  public:
    virtual T GetKey() { return (_key); };
    virtual V GetValue() { return (_value); };
    virtual void SetKey(T keyRef) { _key = keyRef; };
    virtual void SetValue(V& valueRef) { _value = valueRef; };
};

#endif /* F189C0E2_B14E_4223_9FE1_50F57012A521_INCLUDED */
