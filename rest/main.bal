
import ballerina/sql;
import ballerina/http;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;
//import ballerina/log;


configurable int api_port_sec = 9191;

configurable string host = ?;//"sahackathon.mysql.database.azure.com";
configurable int port = ?;//3306;
configurable string user = ?;//"choreo";
configurable string password = ?;//"wso2!234";
configurable string database = ?;//"laslo";

type catalog record {
    string id;
    string title;
    string description;
    string includes;
    string intended_for;
    string color;
    string material;
};


final mysql:Client mysqlClient = check new (host = host, port = port, user = user, password = password, database = database);

http:JwtValidatorConfig config = {
    issuer: "https://api.asgardeo.io/t/hack/oauth2/token", 
    audience: "OmsF4w1l_Oi7VxEnlNqSZChHuBwa",
    signatureConfig: {
        jwksConfig: {
            url: "https://api.asgardeo.io/t/hack/oauth2/jwks"
        }
    }
    };
 
    listener http:Listener securedEP = new (api_port_sec,
        secureSocket = {
            key: {
                certFile: "./resources/public.crt",
                keyFile: "./resources/private.key"
            }
        }
    );
 
    @http:ServiceConfig {
    auth: [
        {
            jwtValidatorConfig: config
        }
    ]
    }
    service / on securedEP {

        //function init() {
        //log:printInfo("API started", host = "0.0.0.0", port = api_port_sec, protocol = "HTTPS");
        //}


        @http:ResourceConfig {
            auth: [
                {
                    jwtValidatorConfig: config,
                    scopes: ["ECom-Admin"]
                }
            ]
        }
        isolated resource function post catalog(@http:Payload catalog post) returns error? {
            sql:ParameterizedQuery updateQuery = `INSERT INTO catalog (id, title, description, includes, intended_for, color, material)
                VALUES (${post.id}, ${post.title}, ${post.description}, ${post.includes}, ${post.intended_for}, ${post.color}, ${post.material})`;
            sql:ExecutionResult _ = check mysqlClient->execute(updateQuery);
            
        }


        @http:ResourceConfig {
            auth: [
                {
                    jwtValidatorConfig: config,
                    scopes: ["ECom-Admin"]
                }
            ]
        }
        isolated resource function delete catalog(string id) returns error? {
            sql:ParameterizedQuery deleteQuery = `DELETE FROM catalog WHERE id = ${id}`;
            sql:ExecutionResult _ = check mysqlClient->execute(deleteQuery);
        }
    }
