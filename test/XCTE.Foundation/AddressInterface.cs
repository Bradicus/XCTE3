using System.Data.SqlClient;
using System;
using System.Collections.Generic;

namespace XCTE.Foundation
{
    public interface AddressInterface
    {
        void Create(SqlTransaction trans, Address o);
        void Update(SqlTransaction trans, Address o);
        IEnumerable<Address> RetrieveAll(SqlTransaction trans);
        Address RetrieveOneById(SqlTransaction trans, int id);
        List<Address> RetrieveSetByCityZipCode(SqlTransaction trans, string city, string zipCode);
        void Delete(SqlTransaction trans, int id);
    }
} // namespace XCTE.Foundation

