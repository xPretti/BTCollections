#ifndef B6362AB1_2E8F_44E2_9B44_12D8D1B17A03_INCLUDED
#define B6362AB1_2E8F_44E2_9B44_12D8D1B17A03_INCLUDED

template<typename T, typename V>
class IHashClassCollect
{
  public:
    //- GET
    virtual int Count() = 0;
    virtual bool Contains(T key) = 0;
    virtual CHashClassEntry<T, V>* Get(T key) = 0;
    virtual bool Get(T key, CHashClassEntry<T, V>*& value) = 0;
    virtual bool Get(T key, V*& value) = 0;

    //- SET
    virtual bool Insert(T key, V* value) = 0;
    virtual bool Set(T key, V* value) = 0;
    virtual bool Replace(T key, V* value) = 0;
    virtual bool Remove(T key) = 0;
    virtual void Clear() = 0;
    virtual void ClearNoDelete() = 0;
  
  public:
    virtual int GetKeyIndex(T key) = 0;

  public:
    virtual CHashClassEntry<T, V>* GetByIndex(int index) = 0;
    virtual bool GetByIndex(int index, CHashClassEntry<T, V>*& value) = 0;
    virtual bool GetByIndex(int index, V*& value) = 0;
};

#endif /* B6362AB1_2E8F_44E2_9B44_12D8D1B17A03_INCLUDED */
