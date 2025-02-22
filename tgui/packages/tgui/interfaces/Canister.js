import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, Icon, Knob, LabeledControls, LabeledList, Section, Tooltip, Slider } from '../components';
import { formatSiUnit } from '../format';
import { Window } from '../layouts';

export const Canister = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    portConnected,
    tankPressure,
    releasePressure,
    defaultReleasePressure,
    minReleasePressure,
    maxReleasePressure,
    valveOpen,
    isPrototype,
    hasHoldingTank,
    holdingTank,
    restricted,
  } = data;
  return (
    <Window width={300} height={232} resizable>
      <Window.Content>
        <Section
          title="Canister"
          buttons={(
            <>
              {!!isPrototype && (
                <Button
                  mr={1}
                  icon={restricted ? 'lock' : 'unlock'}
                  color="caution"
                  content={restricted
                    ? 'Engineering'
                    : 'Public'}
                  onClick={() => act('restricted')} />
              )}
              <Button
                icon="pencil-alt"
                content="Relabel"
                onClick={() => act('relabel')} />
            </>
          )}>
          <LabeledControls>
            <LabeledControls.Item
              minWidth="66px"
              label="Pressure">
              <AnimatedNumber
                value={tankPressure}
                format={value => {
                  if (value < 10000) {
                    return toFixed(value) + ' kPa';
                  }
                  return formatSiUnit(value * 1000, 1, 'Pa');
                }} />
            </LabeledControls.Item>
            <LabeledControls.Item label="Regulator" mr={2}>
              <Box
                position="relative">
                <Slider
                  value={releasePressure}
                  color={!!valveOpen && 'yellow'}
                  fillValue={releasePressure}
                  minValue={minReleasePressure}
                  maxValue={maxReleasePressure}
                  step={5}
                  stepPixelSize={0.75}
                  width={10}
                  format={value => value + "kPa"}
                  onDrag={(e, value) => act('pressure', {
                    pressure: value,
                  })} />
                <Button
                  fluid
                  position="absolute"
                  top="-2px"
                  right="-22px"
                  color="transparent"
                  icon="fast-forward"
                  onClick={() => act('pressure', {
                    pressure: maxReleasePressure,
                  })} />
                <Button
                  fluid
                  position="absolute"
                  top="16px"
                  right="-22px"
                  color="transparent"
                  icon="undo"
                  onClick={() => act('pressure', {
                    pressure: defaultReleasePressure,
                  })} />
              </Box>
            </LabeledControls.Item>
            <LabeledControls.Item label="Valve">
              <Button
                my={0.5}
                width="75px"
                lineHeight={2}
                fontSize="11px"
                color={valveOpen
                  ? (hasHoldingTank ? 'caution' : 'danger')
                  : null}
                content={valveOpen ? 'Open' : 'Closed'}
                onClick={() => act('valve')} />
            </LabeledControls.Item>
            <LabeledControls.Item
              mr={1}
              label="Port">
              <Box position="relative">
                <Icon
                  size={1.25}
                  name={portConnected ? 'plug' : 'times'}
                  color={portConnected ? 'good' : 'bad'} />
                <Tooltip
                  content={portConnected
                    ? 'Connected'
                    : 'Disconnected'}
                  position="top" />
              </Box>
            </LabeledControls.Item>
          </LabeledControls>
        </Section>
        <Section
          title="Holding Tank"
          buttons={!!hasHoldingTank && (
            <Button
              icon="eject"
              color={valveOpen && 'danger'}
              content="Eject"
              onClick={() => act('eject')} />
          )}>
          {!!hasHoldingTank && (
            <LabeledList>
              <LabeledList.Item label="Label">
                {holdingTank.name}
              </LabeledList.Item>
              <LabeledList.Item label="Pressure">
                <AnimatedNumber value={holdingTank.tankPressure} /> kPa
              </LabeledList.Item>
            </LabeledList>
          )}
          {!hasHoldingTank && (
            <Box color="average">
              No Holding Tank
            </Box>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
