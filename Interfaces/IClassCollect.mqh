#ifndef F892EF5C_C1E7_4543_B24D_B747B4D68684_INCLUDED
#define F892EF5C_C1E7_4543_B24D_B747B4D68684_INCLUDED

#include "IClassCollect.mqh"

template<typename T>
class IClassCollect : public ICollect<T>
{
  public:
    //- SET
    virtual bool RemovePointer(int index) = 0;
    virtual bool RemovePointerByNotEqual(int index, T compareValue) = 0;
    virtual bool RemoveNoDelete(int index) = 0;
    virtual void ClearNoDelete() = 0;
    virtual bool ResizeNoRemove(uint size) = 0;
};

#endif /* F892EF5C_C1E7_4543_B24D_B747B4D68684_INCLUDED */
