#ifndef ICOLLECT_INCLUDED
#define ICOLLECT_INCLUDED

template<typename T>
class ICollect
{
  public:
    //- GET
    virtual int Count() = 0;
    virtual int Contains(T value) = 0;
    virtual T Get(int index) = 0;
    virtual bool Get(int index, T& value) = 0;
    virtual bool Copy(T& values[]) = 0;

    //- SET
    virtual bool Insert(T value) = 0;
    virtual bool Set(int index, T value) = 0;
    virtual bool Replace(int index, T value) = 0;
    virtual bool Remove(int index) = 0;
    virtual bool Resize(uint size) = 0;
    virtual void Clear() = 0;

  public:
    // Defines
    //- GET
    virtual bool WasModified() = 0;
    virtual bool WasModified(bool newValue) = 0;

    //- SET
    virtual void SetReserve(int value) = 0;
    virtual void SetModified(bool value) = 0;
};

#endif /* ICOLLECT_INCLUDED */