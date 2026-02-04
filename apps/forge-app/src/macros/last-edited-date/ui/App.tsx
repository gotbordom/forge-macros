import ForgeUI, { Macro, Text } from '@forge/ui';
import { formatDateIso } from '../../../../shared/date-format';

const App = () => {
  const placeholderLastEditedIso = new Date().toISOString();

  return <Macro app={<Text>Last edited: {formatDateIso(placeholderLastEditedIso)}</Text>} />;
};

export default App;
