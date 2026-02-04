import ForgeUI, { Strong, Text } from '@forge/ui';

export type KeyValueRowProps = {
  label: string;
  value: string;
};

export const KeyValueRow = ({ label, value }: KeyValueRowProps) => {
  return (
    <Text>
      <Strong>{label}:</Strong> {value}
    </Text>
  );
};
