export default (query: any) => {
  let fidx, lidx;
  let method = "";
  if (query !== undefined) {
    fidx = query.indexOf("{");
    if (query.includes("(")) {
      lidx = query.lastIndexOf("(");
    } else {
      let idx = query.indexOf("{");
      lidx = query.indexOf("{", idx + 1);
    }

    method = query.substring(fidx + 1, lidx).trim();
  }
  return method;
};
