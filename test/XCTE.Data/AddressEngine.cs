using XCTE.Foundation;
using System;
using System.Data.SqlClient;
using System.Collections.Generic;

namespace XCTE.Data
{
    
    public class AddressEngine : AddressInterface
    {
        ///
        /// Create new record for this model
        ///
        public void Create(SqlTransaction trans, Address o)
        {
            string sql = @"INSERT INTO Address(
                aId,
                aStreet1,
                aStreet2,
                aCity,
                aState,
                aZipCode
            ) VALUES (
                @aId,
                @aStreet1,
                @aStreet2,
                @aCity,
                @aState,
                @aZipCode
            )";
            
            try
            {
                using(SqlCommand cmd = new SqlCommand(sql, trans.Connection))
                {
                    cmd.Parameters.AddWithValue("@aStreet1", o.Street1);
                    cmd.Parameters.AddWithValue("@aStreet2", o.Street2);
                    cmd.Parameters.AddWithValue("@aCity", o.City);
                    cmd.Parameters.AddWithValue("@aState", o.State);
                    cmd.Parameters.AddWithValue("@aZipCode", o.ZipCode);
                    
                    var newId = cmd.ExecuteScalar();
                    o.Id = Convert.ToInt32(newId);
                }
            }
            catch(Exception e)
            {
                throw new Exception("Error inserting Address into database with id = " + o.Id, e);
            };
        }
        
        ///
        /// Update the record for this model
        ///
        public void Update(SqlTransaction trans, Address o)
        {
            string sql = @"UPDATE Address SET 
                Street1 = @Street1,
                Street2 = @Street2,
                City = @City,
                State = @State,
                ZipCode = @ZipCode
            WHERE Id = @Id";
            
            try
            {
                using(SqlCommand cmd = new SqlCommand(sql, trans.Connection))
                {
                    cmd.Parameters.AddWithValue("@Id", o.Id);
                    cmd.Parameters.AddWithValue("@Street1", o.Street1);
                    cmd.Parameters.AddWithValue("@Street2", o.Street2);
                    cmd.Parameters.AddWithValue("@City", o.City);
                    cmd.Parameters.AddWithValue("@State", o.State);
                    cmd.Parameters.AddWithValue("@ZipCode", o.ZipCode);
                    cmd.ExecuteScalar();
                }
            }
            catch(Exception e)
            {
                throw new Exception("Error updating Address with id = " + o.Id, e);
            };
        }
        
        /// <summary>
        /// Reads data set from sql database
        /// </summary>
        public IEnumerable<Address> RetrieveAll(SqlTransaction trans)
        {
            List<Address> resultList = new List<Address>();
            string sql = @"SELECT 
                Id,
                Street1,
                Street2,
                City,
                State,
                ZipCode
            FROM Address";
            
            try
            {
                using(SqlCommand cmd = new SqlCommand(sql, trans.Connection))
                {
                    
                    SqlDataReader results = cmd.ExecuteReader();
                    while(results.Read())
                    {
                        var o = new Address();
                        o.Id = Convert.ToInt32(results["Id"]);
                        o.Street1 = Convert.ToString(results["Street1"]);
                        o.Street2 = Convert.ToString(results["Street2"]);
                        o.City = Convert.ToString(results["City"]);
                        o.State = Convert.ToString(results["State"]);
                        o.ZipCode = Convert.ToString(results["ZipCode"]);
                    }
                }
            }
            catch(Exception e)
            {
                throw new Exception("Error retrieving all items from Address", e);
            };
            
            return resultList;
        }
        
        /// <summary>
        /// Reads one result using the specified filter parameters
        /// </summary>
        public Address RetrieveOneById(SqlTransaction trans, int id)
        {
            var o = new Address();
            string sql = @"SELECT TOP 1 
                id,
                street1,
                street2,
                city,
                state,
                zipCode
            FROM Address
            WHERE 
                id = @id";
            
            try
            {
                using(SqlCommand cmd = new SqlCommand(sql, trans.Connection))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    SqlDataReader results = cmd.ExecuteReader();
                    while(results.Read())
                    {
                        o.Id = Convert.ToInt32(results["id"]);
                        o.Street1 = Convert.ToString(results["street1"]);
                        o.Street2 = Convert.ToString(results["street2"]);
                        o.City = Convert.ToString(results["city"]);
                        o.State = Convert.ToString(results["state"]);
                        o.ZipCode = Convert.ToString(results["zipCode"]);
                    }
                }
            }
            catch(Exception e)
            {
                throw new Exception("Error retrieving one item from Address", e);
            };
            
            return o;
        }
        
        /// <summary>
        /// Reads set of results using the specified filter parameters
        /// </summary>
        public List<Address> RetrieveSetByCityZipCode(SqlTransaction trans, string city, string zipCode)
        {
            List<Address> resultList = new List<Address>();
            string sql = @"SELECT 
                id,
                street1,
                street2,
                city,
                state,
                zipCode
            FROM Address
            WHERE 
                city = @city AND zipCode = @zipCode";
            
            try
            {
                using(SqlCommand cmd = new SqlCommand(sql, trans.Connection))
                {
                    cmd.Parameters.AddWithValue("@city", city);
                    cmd.Parameters.AddWithValue("@zipCode", zipCode);
                    SqlDataReader results = cmd.ExecuteReader();
                    while(results.Read())
                    {
                        var o = new Address();
                        o.Id = Convert.ToInt32(results["id"]);
                        o.Street1 = Convert.ToString(results["street1"]);
                        o.Street2 = Convert.ToString(results["street2"]);
                        o.City = Convert.ToString(results["city"]);
                        o.State = Convert.ToString(results["state"]);
                        o.ZipCode = Convert.ToString(results["zipCode"]);
                        
                        resultList.Add(o);
                    }
                }
            }
            catch(Exception e)
            {
                throw new Exception("Error retrieving all items from Address", e);
            };
            
            return resultList;
        }
        
        ///
        /// Delete the record for the model with this id
        ///
        public void Delete(SqlTransaction trans, int id)
        {
            string sql = @"DELETE FROM Address WHERE Id=@Id";
            
            try
            {
                using(SqlCommand cmd = new SqlCommand(sql, trans.Connection))
                {
                    cmd.Parameters.AddWithValue("@Id", id);
                }
            }
            catch(Exception e)
            {
                throw new Exception("Error deleting Address with id = " + id, e);
            }
        }
        
    }
} // namespace XCTE.Data

