import DeviceDetector from "device-detector-js";
import jwt from "jsonwebtoken";
import helper from "../helper/index";

export default {
  add: async (ctx: any, method: string): Promise<string> => {
    let id: string = "";
    let originator_type = null;
    let originator = null;    
    let headers = ctx.req.headers;
    //console.log("headers: ", headers);    
    let url = headers["host"];
    //url += ctx.req.baseUrl;
    let referer = headers["referer"];
    let x_ip: string = headers["xip"];
    let ip: string = x_ip;
    let query = ctx.params;
    if (query["variables"] && query["variables"]["input"]) {
      delete query["variables"]["input"]["password"];
    }
    
    let request = {
      headers: headers,
      body: query,
    };
    const deviceDetector = new DeviceDetector();
    const userAgent = headers["user-agent"];
    const device = deviceDetector.parse(userAgent!);

    let authorization = headers["authorization"];
    if (authorization !== undefined) {
      let token: string = authorization.replace("Bearer", "").trim();
      let user: any = jwt.decode(token);
      originator_type = user?.role;
      originator = user?.id;
    }

    let logger = {
      url: url,
      referer: decodeURI(referer),
      browser: device.client?.name,
      device: device.device?.type,
      brand: device.device?.brand,
      source: "API",
      method: method,
      originator_type: originator_type,
      originator: originator,
      starttime: new Date().toISOString(),
      ip: ip,
      request: request,
    };
    id = await helper.log.add(logger);

    return id;
  },
  update: async (id: string, status: string, data: any): Promise<string> => {
    console.log("id:", id);
    console.log("status:", status);

    let logger = {
      endtime: new Date(),
      response: JSON.stringify(data),
      status: status,
    };
    return await helper.log.update(id, logger);
  },
};
