import _ from "lodash";
import md5 from "js-md5";

export default (...args) => {
  return _.map(args, md5).join("+");
}

export function idExists(l, id) {
  return _(l).map(x => x.id === id).some();
}
