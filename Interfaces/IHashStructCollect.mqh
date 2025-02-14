#ifndef ABD74EFC_6059_4EB6_9552_8EBD6688BF0F_INCLUDED
#define ABD74EFC_6059_4EB6_9552_8EBD6688BF0F_INCLUDED

#include "../Base/HashStructEntry.mqh"

template<typename T, typename V>
class IHashStructCollect
{
  public:
    //- GET
    virtual int Count() = 0;
    virtual bool Contains(T key) = 0;
    virtual CHashStructEntry<T, V>* Get(T key) = 0;
    virtual bool Get(T key, CHashStructEntry<T, V>*& value) = 0;
    virtual bool Get(T key, V& value) = 0;

    //- SET
    virtual bool Insert(T key, V& value) = 0;
    virtual bool Set(T key, V& value) = 0;
    virtual bool Replace(T key, V& value) = 0;
    virtual bool Remove(T key) = 0;
    virtual void Clear() = 0;
    
  public:
    virtual int GetKeyIndex(T key) = 0;

  public:
    virtual CHashStructEntry<T, V>* GetByIndex(int index) = 0;
    virtual bool GetByIndex(int index, CHashStructEntry<T, V>*& value) = 0;
    virtual bool GetByIndex(int index, V& value) = 0;
};

#endif /* ABD74EFC_6059_4EB6_9552_8EBD6688BF0F_INCLUDED */
