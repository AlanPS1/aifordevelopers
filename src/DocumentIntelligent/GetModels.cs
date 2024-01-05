using System.Net;
using System.Text.Json;
using Contoso;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;

namespace DocumentIntelligent
{
    public class GetModels
    {
        private readonly ILogger _logger;
        private readonly IDocumentIntelligentService _documentIntelligent;

        public GetModels(ILoggerFactory loggerFactory, IDocumentIntelligentService documentIntelligent)
        {
            _logger = loggerFactory.CreateLogger<GetModels>();
            _documentIntelligent = documentIntelligent;
        }

        [Function("GetModels")]
        public async Task<HttpResponseData> Run([HttpTrigger(AuthorizationLevel.Function, "get")] HttpRequestData req)
        {
            try
            {
                var documents = await _documentIntelligent.GetModels();

                // Return the list of documents            
                var response = req.CreateResponse(HttpStatusCode.OK);
                response.Headers.Add("Content-Type", "application/json; charset=utf-8");
                response.WriteString(JsonSerializer.Serialize(documents));

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, ex.Message);
                return req.CreateResponse(HttpStatusCode.InternalServerError);
            }
        }

        [Function("DeleteModel")]
        public async Task<HttpResponseData> DeleteModel([HttpTrigger(AuthorizationLevel.Function, "delete")] HttpRequestData req)
        {
            try
            {
                var query = System.Web.HttpUtility.ParseQueryString(req.Url.Query);
                var modelId = query["modelId"];

                if (string.IsNullOrEmpty(modelId))
                    return req.CreateResponse(HttpStatusCode.BadRequest);

                await _documentIntelligent.DeleteModel(modelId);

                // Return the list of documents            
                var response = req.CreateResponse(HttpStatusCode.NoContent);
                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, ex.Message);
                return req.CreateResponse(HttpStatusCode.InternalServerError);
            }
        }
    }
}
