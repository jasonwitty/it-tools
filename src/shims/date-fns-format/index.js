// ESM shim to provide a named export `format` for date-fns default export
import formatDefault from 'date-fns/format';

export const format = formatDefault;
export default formatDefault;

